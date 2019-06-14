<?php   
    /*********************************************************************
	 Fonte: form_log.php                                                 
	 Autor: Gabriel                                                     
	 Data : Setembro/2011                Última Alteração: 26/12/2012 
	                                                                  
	 Objetivo  : Mostrar o form com os detalhes da opcao P.                                 
	                                                                  
	 Alterações:  18/12/2012 - Alteração layout tela para novo padrao (Daniel).
	 
				  26/12/2012 - Tratar paginacao da listagem (Gabriel) 

				  14/03/2013 - Incluir nova informacao de Origem (Gabriel)			
	**********************************************************************/
	
	$i = 0; 
?>
	var strHTML = ''; 
	strHTML += '<div id="divResultado">';
	strHTML += ' <form class="formulario">';
	strHTML += '    <fieldset>';
	strHTML += '    <div class="divRegistros">';
	strHTML	+= '	   <table>';
	strHTML	+= '	     <thead>';
	strHTML	+= '     		<tr>';	
	strHTML	+= '  			   <th> Hora 	 </th>';
	strHTML	+= '	  		   <th> Conta/dv </th>';
	strHTML += '      		   <th> Nome     </th>';
	strHTML	+= '       		   <th> Valor    </th>';
	strHTML	+= '       		   <th> Origem   </th>';
	strHTML += '	  		</tr>';										      																										
	strHTML += '  	 	</thead>';	
	strHTML += '   		<tbody>';	
	<?	
			foreach($logCompleto as $log) {  								
						
				$nrdconta = ($tpoperac == '2' && $tpdenvio == '2' ) ? formataContaDV(getByTagName($log->tags,'nrctarem')) : formataContaDV(getByTagName($log->tags,'nrctadst'));	
				$nmprimtl = getByTagName($log->tags,'nmpridst');
				$dstransa = getByTagName($log->tags,'dstransa');
				$vllanmto = number_format(str_replace(",",".",getByTagName($log->tags,'vllanmto')),2,",","."); 
				$dspesrem = (getByTagName($log->tags,'inpesrem') == "1" ) ? "cpf" : "cnpj";
				$dspesdst = (getByTagName($log->tags,'inpesdst') == "1" ) ? "cpf" : "cnpj";
				$dspacrem = getByTagName($log->tags,'dspacrem');
								
	?>				   
    strHTML += '        <tr onclick="selecionaOpe(<? echo $i; ?>);" >'; 	
	strHTML += '          <td> <? echo $dstransa; ?> </td>';
	strHTML += '          <td> <? echo $nrdconta; ?> </td>';
	strHTML += '          <td> <? echo $nmprimtl; ?> </td>';
	strHTML += '		  <td> <? echo $vllanmto; ?> </td>';	
	strHTML += '		  <td> <? echo $dspacrem; ?> </td>';		
	strHTML += '       </tr>';

	objLog   = new Object();
	objLog.cdagerem = "<? if  (getByTagName($log->tags,'cdagerem') != "0") { echo getByTagName($log->tags,'cdagerem') . " - " . getByTagName($log->tags,'dsagerem'); } ?>";
	objLog.cdagedst = "<? echo getByTagName($log->tags,'cdagedst') . " - " . getByTagName($log->tags,'dsagedst'); ?>";
	objLog.nrctarem = "<? echo formataContaDV(getByTagName($log->tags,'nrctarem')); ?>";
	objLog.nrctadst = "<? echo formataContaDV(getByTagName($log->tags,'nrctadst')); ?>";
	objLog.nmprirem = "<? echo getByTagName($log->tags,'nmprirem'); ?>";
	objLog.nmpridst = "<? echo getByTagName($log->tags,'nmpridst'); ?>";
	objLog.nrcpfrem = "<? if (getByTagName($log->tags,'nrcpfrem') != "0") { echo formatar(getByTagName($log->tags,'nrcpfrem'),$dspesrem);  }  ?>"; 
	objLog.nrcpfdst = "<? echo formatar(getByTagName($log->tags,'nrcpfdst'),$dspesdst); ?>";
	objLog.dspacrem = "<? echo $dspacrem; ?>";

	detalhes[<?php echo $i; ?>] = objLog;
	<? 			$i++;  
			} ?>				 
	<? 		if ($i == 0) { ?>
	strHTML += '        <br/> <tr>  * N&atilde;o h&aacute; opera&ccedil;&otilde;es para estas condi&ccedil;&otilde;es. </tr>';
	<?		 } ?>	
	strHTML += '     </tbody>';
	strHTML += '   </table>';
	strHTML += '  </div>';

	strHTML += '<div id="divPesquisaRodape" class="divPesquisaRodape">';
	strHTML += '<table>';	
	strHTML += '<tr>';
	strHTML += '<td>';
	<?
		if (isset($qtregist) && $qtregist == 0) $nriniseq = 0;
				
			if ($nriniseq > 1) { 
	?> 
	strHTML += '<a class="paginacaoAnt"><<< Anterior</a>';
	<? 
		} else {
	?> 
	strHTML += '&nbsp;'; 
	<?
		}
	?>
	strHTML += '</td>';
	strHTML += '<td>';
	<?
		if (isset($nriniseq)) { 
	?> 
	strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? if (( $nriniseq + $nrregist  ) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?> ';
	<?
		}
	?>
	strHTML += '</td>';
	strHTML += '<td>';
	<?
		if ($qtregist > ($nriniseq + $nrregist - 1)) {
	?> 
	strHTML += '<a class="paginacaoProx">Pr&oacute;ximo >>></a>';
	<?
		} else {
	?>
	strHTML += '&nbsp;';
	<?
		}
	?>			
	strHTML += '</td>';
	strHTML += '</tr>';
	strHTML += '</table>';
    strHTML += '</div>';
	

		
	strHTML += '    </fieldset>';
	strHTML += '	</form>';
	strHTML += '</div>';	
	
	<?
	echo '$("#divOpcao_L").append(strHTML);';
	
	echo 'controlaLayout("divResultado");';

	echo '$("a.paginacaoProx").unbind("click").bind("click" , function() {
		manter_rotina("'. ($nriniseq + $nrregist) .'");		
	});';	
	
	echo '$("a.paginacaoAnt").unbind("click").bind("click", function() {
		manter_rotina("'. ($nriniseq - $nrregist) .'");
	});';
	
	echo '$("#divPesquisaRodape","#divTela").formataRodapePesquisa();';
	
	?>