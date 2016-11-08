<? 
/*!
 * FONTE        : tabela_integralizacao.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 20/09/2013 
 * OBJETIVO     : Tabela de integralizacoes de capital realizadas no dia.
 */	
?>

lstLancamentos = new Array();

var strHTML = "";

strHTML += '<div class="divRegistros" align="center">';	
strHTML += '	<table>';
strHTML += '		<thead>';
strHTML += '			<tr>';
strHTML += '				<th></th>';
strHTML += '				<th>Docmto</th>';
strHTML += '				<th>Valor</th>';
strHTML += '			</tr>';
strHTML += '		</thead>';
strHTML += '		<tbody>';

			<? for ($i = 0; $i < $count; $i++) {
			
				$nrdocmto = formataNumericos("zz.zzz.zzz",getByTagName($lancamentos[$i]->tags,"NRDOCMTO"),".");
				$vllanmto = number_format(str_replace(",",".",getByTagName($lancamentos[$i]->tags,"VLLANMTO")),2,",",".");
				$lctrowid = getByTagName($lancamentos[$i]->tags,"LCTROWID");
			?>
				objLancamentos = new Object();
				objLancamentos.lctrowid = "<?php echo $lctrowid; ?>";
				lstLancamentos[<?php echo $i; ?>] = objLancamentos;
				
strHTML += '				<tr id="trLancamentos<?php echo $i; ?>" style="cursor: pointer;">';
strHTML += '					<td><input type="checkbox" name="appest<?php echo $i;?>" id="appest<?php echo $i;?>" onClick="selecionaIntegralizacao(<?php echo $i; ?>);">';
strHTML += '					<td><?php echo $nrdocmto; ?></td>';
strHTML += '					<td><?php echo $vllanmto; ?></td>';
strHTML += '				</tr>';
			<? } ?>			
strHTML += '		</tbody>';
strHTML += '	</table>';
strHTML += '</div>';
strHTML += '<input type="image" style="padding-top: 7px" id="btnEstorna" src="<?php echo $UrlImagens; ?>botoes/estornar_integralizacao.gif" onClick="mostraSenha();return false;">';

$('#divEstorno').html(strHTML);
controlaLayout('ESTORNO');

hideMsgAguardo();

blockBackground(parseInt($("#divRotina").css("z-index")));

