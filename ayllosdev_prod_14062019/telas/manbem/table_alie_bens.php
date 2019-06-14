	<table class="table_alie_veiculo">
		<thead>
			<tr>
				<th class="thd_menor"></th>
				<th>Marca</th>
				<th>Modelo</th>
				<th>Chassi</th>
				<th>Situa&ccedil;&atilde;o</th>
			</tr>
		</thead>
		<tbody>
			<?php				
				foreach($registrosBens as $r)
				{
			?>
					<tr>
						<td  class="thd_menor"><input type="radio" name="nrbem" value="<?php echo getByTagName($r->tags,'idseqbem') ?>"></td>
						<td><?php echo getByTagName($r->tags,'dsmarbem') ?></td>
						<td><?php echo getByTagName($r->tags,'dsbemfin') ?></td>
						<td><?php echo getByTagName($r->tags,'dschassi') ?></td>
						<td><?php echo getByTagName($r->tags,'dssitgrv') ?></td>
					</tr>
			<?
				}				
			?>
		</tbody>
	</table>