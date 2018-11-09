<? 
/*!
 * FONTE        : tab_carga.php
 * CRIAÇÃO      : Thaise Medeiros - Envolti
 * DATA CRIAÇÃO : Outubro/2018
 * OBJETIVO     : Tabela que apresenta o as cargas do score.
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>

<div id="divCarga" style="display:block; margin-top: 20px;">
	<div class="divRegistros">
		<table class="">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Código'); ?></th>
					<th><? echo utf8ToHtml('Modelo Score'); ?></th>
					<th><? echo utf8ToHtml('Data Base'); ?></th>
					<th><? echo utf8ToHtml('Início Carga'); ?></th>
					<th><? echo utf8ToHtml('Término Carga'); ?></th>
					<th><? echo utf8ToHtml('Usuário Responsável'); ?></th>
					<th><? echo utf8ToHtml('Quantidade'); ?></th>
					<th><? echo utf8ToHtml('Quantidade Física'); ?></th>
					<th><? echo utf8ToHtml('Quantidade Jurídica'); ?></th>
					<th><? echo utf8ToHtml('Situação'); ?></th>
				</tr>
			</thead>
			<tbody><?
			if(count($cargas) == 0){
				?>
				<tr>
					<td colspan="11" style="width: 80px; text-align: center;">
						<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
						<b>N&atilde;o h&aacute; registros para exibir.</b>
					</td>
				</tr>
				<?
			} else{
				foreach($cargas as $carga){
					?>
					<tr id="<? echo getByTagName($carga->tags, 'cdmodelo'); ?>">
						<td>
							<span><? echo getByTagName($carga->tags,'cdmodelo'); ?></span>
							<? echo getByTagName($carga->tags,'cdmodelo'); ?>
						</td>
						<td id="dsmodelo">
							<span><? echo getByTagName($carga->tags,'dsmodelo'); ?></span>
							<? echo getByTagName($carga->tags,'dsmodelo'); ?>
						</td>
						<td id="dtbase">
							<span><? echo getByTagName($carga->tags,'dtbase'); ?></span>
							<? echo getByTagName($carga->tags,'dtbase'); ?>
						</td>
						<td>
							<span><? echo getByTagName($carga->tags,'dtinicio'); ?></span>
							<? echo getByTagName($carga->tags,'dtinicio'); ?>
						</td>
						<td>
							<span><? echo getByTagName($carga->tags,'dttermino'); ?></span>
							<? echo getByTagName($carga->tags,'dttermino'); ?>
						</td>
						<td>
							<span><? echo getByTagName($carga->tags,'cdoperad'); ?></span>
							<? echo getByTagName($carga->tags,'cdoperad'); ?>
						</td>
						<td>
							<span><? echo getByTagName($carga->tags,'qtregistro'); ?></span>
							<? echo getByTagName($carga->tags,'qtregistro'); ?>
						</td>
						<td>
							<span><? echo getByTagName($carga->tags,'qtregis_fisica'); ?></span>
							<? echo getByTagName($carga->tags,'qtregis_fisica'); ?>
						</td>
						<td>
							<span><? echo getByTagName($carga->tags,'qtregis_juridi'); ?></span>
							<? echo getByTagName($carga->tags,'qtregis_juridi'); ?>
						</td>
						<td>
							<span><? echo getByTagName($carga->tags,'dssituac'); ?></span>
							<? echo getByTagName($carga->tags,'dssituac'); ?>
						</td>
						<input type="hidden" id="dsrejeicao" name="dsrejeicao" value="<? echo getByTagName($carga->tags,'dsrejeicao'); ?>" />
					</tr>
					<?
				}
			}
			?>
			</tbody>
		</table>
	</div>
</div>
<div id="divBotoes" style="padding-bottom: 15px;">
	<a href="#" class="botao" id="btVoltar">Voltar</a> 
</div>

<div id="divMotivo" style="height:50px; display: none;">
		<table width="100%">
			<thead>
				<tr>
					<th style="text-align: left;"><? echo utf8ToHtml('Motivo Rejeição:'); ?></th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>
						<textarea name="txtdsrejeicao" id="txtdsrejeicao" cols="5" readonly="readonly" disabled="disabled" style="width: 100%;" ></textarea>
					</td>
				</tr>
			</tbody>
		</table>
	</div>