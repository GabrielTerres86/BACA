<? 
/*!
 * FONTE        : realiza_pesquisa_motivo_devdoc.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 01/03/2014
 * OBJETIVO     : Lista de Motivos de devolucao do documento
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<div id="divPesquisaMotivoDevdoc" class="divPesquisaMotivoDevdoc">
	<table>
		<tbody>				 
			<tr onClick="selecionaMotivo('51'); return false;">					
				<td style="width:40px; font-size:11px ;text-align:center;">51</td>				
				<td style="text-align:left;font-size:11px;">Diverg&ecirc;ncia no valor recebido</td>  
			</tr>
			<tr onClick="selecionaMotivo('52'); return false;">					
				<td style="width:40px; font-size:11px ;text-align:center;">52</td>				
				<td style="text-align:left;font-size:11px;">Recebimento efetuado fora do prazo</td>  
			</tr>
			<tr onClick="selecionaMotivo('53'); return false;">					
				<td style="width:40px; font-size:11px ;text-align:center;">53</td>				
				<td style="text-align:left;font-size:11px;">Apresenta&ccedil;&atilde;o indevida</td>  
			</tr>
			<tr onClick="selecionaMotivo('56'); return false;">					
				<td style="width:40px; font-size:11px ;text-align:center;">56</td>				
				<td style="text-align:left;font-size:11px;">Transpar&ecirc;ncia insuficiente para a finalidade indicada</td>  
			</tr>
			<tr onClick="selecionaMotivo('57'); return false;">					
				<td style="width:40px; font-size:11px ;text-align:center;">57</td>
				<td style="text-align:left;font-size:11px;">Diverg&ecirc;ncia ou n&atilde;o preenchimento de informa&ccedil;&atilde;o obrigat&oacute;ria</td>  
			</tr>
			<tr onClick="selecionaMotivo('58'); return false;">					
				<td style="width:40px; font-size:11px ;text-align:center;">58</td>				
				<td style="text-align:left;font-size:11px;">Dep&oacute;sito em conta de poupan&ccedil;a recusado</td>  
			</tr>
			<tr onClick="selecionaMotivo('59'); return false;">					
				<td style="width:40px; font-size:11px ;text-align:center;">59</td>				
				<td style="text-align:left;font-size:11px;">Aus&ecirc;ncia da express&atilde;o "Transfer&ecirc;ncia internacional em reais - Natureza da opera&ccedil;&atilde;o"</td>  
			</tr>
			<tr onClick="selecionaMotivo('62'); return false;">					
				<td style="width:40px; font-size:11px ;text-align:center;">62</td>				
				<td style="text-align:left;font-size:11px;">Aus&ecirc;ncia ou diverg&ecirc;ncia na indica&ccedil;&atilde;o para conta conjunta (dois CPF) e vice-versa</td>  
			</tr>
			<tr onClick="selecionaMotivo('66'); return false;">					
				<td style="width:40px; font-size:11px ;text-align:center;">66</td>				
				<td style="text-align:left;font-size:11px;">DOC D de conta individual (&uacute;nico CPF) para conta conjunta (dois CPF) e vice-versa</td>  
			</tr>
			<tr onClick="selecionaMotivo('67'); return false;">					
				<td style="width:40px; font-size:11px ;text-align:center;">67</td>				
				<td style="text-align:left;font-size:11px;">DOC D sem a indica&ccedil;&atilde;o do tipo de conta debitada ou creditada</td>  
			</tr>
		</tbody>
	</table>
	<br clear="both" />
</div>

<script type="text/javascript">		
	hideMsgAguardo();
	bloqueiaFundo($("#divPesquisaMotivoDevdoc"));
</script>