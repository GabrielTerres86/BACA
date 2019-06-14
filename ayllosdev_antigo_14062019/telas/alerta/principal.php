<?php

	/*************************************************************************
	*  Fonte: principal.php                                               
	*  Autor: Adriano                                                  
	*  Data : Fevereiro/2013                       Última Alteração: 10/07/2018
	*                                                                   
	*  Objetivo  : Mostrar as rotinas da tela ALERTA.             
	*                                                                 
	*  Alterações: 30/05/2014 - Ajuste para retirar caracteres de quebra de linha
	*							do campo dsjusinc.
	*  							(Jorge/Rosangela) - Emergencial		
	*              
	*		       10/07/2018 - Ajuste para nao permitir caractere invalido. (PRB0040139 - Kelvin)
	***********************************************************************/


	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	$nrcpfcgc = (isset($_POST["consucpf"])) ? $_POST["consucpf"] : 0;
	$nmpessoa = (isset($_POST["consupes"])) ? $_POST["consupes"] : '';
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	
	if($cddopcao == "C" || $cddopcao == "E"){
	
		$xmlConsulta  = "";
		$xmlConsulta .= "<Root>";
		$xmlConsulta .= " <Cabecalho>";
		$xmlConsulta .= "    <Bo>b1wgen0117.p</Bo>";
		$xmlConsulta .= "    <Proc>consultar_cad_restritivo</Proc>";
		$xmlConsulta .= " </Cabecalho>";
		$xmlConsulta .= " <Dados>";
		$xmlConsulta .= "	 <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlConsulta .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlConsulta .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlConsulta .= "	 <idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xmlConsulta .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xmlConsulta .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlConsulta .= "	 <cddopcao>".$cddopcao."</cddopcao>";
		$xmlConsulta .= "    <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
		$xmlConsulta .= "    <nmpessoa>".$nmpessoa."</nmpessoa>";
		$xmlConsulta .= "	 <nrregist>".$nrregist."</nrregist>";
		$xmlConsulta .= "	 <nriniseq>".$nriniseq."</nriniseq>";
		$xmlConsulta .= "	 <flgpagin>yes</flgpagin>";
		$xmlConsulta .= " </Dados>";
		$xmlConsulta .= "</Root>";
			
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlConsulta);
			
		$xmlObjConsulta = getObjectXML(removeCaracteresInvalidos($xmlResult));
			
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjConsulta->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjConsulta->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}   

		$registros = $xmlObjConsulta->roottag->tags[0]->tags;
		$qtregist = $xmlObjConsulta->roottag->tags[0]->attributes["QTREGIST"];
		
				
		if ($qtregist == 0) { 			
		   ?>
		   
			<script type="text/javascript">
				if( $('#cpfcgc','#divOpcoesConsulta').prop('checked')){
					showError('inform','Nenhum registro foi encontrado.','Alerta - Ayllos','$(\'#consucpf\',\'#divOpcoesConsulta\').focus(); ');
				}else if( $('#nome','#divOpcoesConsulta').prop('checked') ){
						   showError('inform','Nenhum registro foi encontrado.','Alerta - Ayllos','$(\'#consupes\',\'#divOpcoesConsulta\').focus(); ');
				}		
			</script>
			<?
		} else { ?>
			 <script type="text/javascript">
				var strHTML = '';		 
				
				strHTML += '<fieldset id="Informacoes">';
				strHTML += '<legend><? if($qtregist > 0){echo "Registro(s) encontrado(s)";}else{echo "Registro(s) encontrado(s)";} ?></legend>';
				strHTML += '<div class="divRegistros">';
				strHTML += '  <table>';
				strHTML += '    <thead>';
				strHTML += '       <tr>';
				strHTML += '          <th>Sequ&ecirc;ncia</th>';
				strHTML += '          <th>Situa&ccedil;&atilde;o</th>';
				strHTML += '          <th>Nome</th>';
				strHTML += '          <th>CPF/CNPJ</th>';
				strHTML += '       </tr>';
				strHTML += '    </thead>';
				strHTML += '    <tbody>';
				<? foreach( $registros as $result ) {     	
					//altera caracteres de qubra de linha por espaco em branco
					$aux_dsjusinc = getByTagName($result->tags,'dsjusinc');
					$aux_dsjusinc = str_replace("\r", '',  $aux_dsjusinc);
					$aux_dsjusinc = str_replace("\n", ' ', $aux_dsjusinc);
					
					$aux_dsjusexc = getByTagName($result->tags,'dsjusexc');
					$aux_dsjusexc = str_replace("\r", '',  $aux_dsjusexc);
					$aux_dsjusexc = str_replace("\n", ' ', $aux_dsjusexc);

				?>
				strHTML += '     	       <tr>'; 	
				strHTML += '     	   	     <td><span><? echo getByTagName($result->tags,'nrregres'); ?></span><? echo getByTagName($result->tags,'nrregres'); ?> </td>';
				strHTML += '      	         <td><span><? echo getByTagName($result->tags,'cdsitreg'); ?></span><? if(getByTagName($result->tags,'cdsitreg') == 1) { $dscsitua = "INCLUIDO"; }else{ $dscsitua = "EXCLUIDO";} echo $dscsitua; ?> </td>';
				strHTML += '       	         <td><span><? echo getByTagName($result->tags,'nmpessoa'); ?></span><? echo getByTagName($result->tags,'nmpessoa'); ?> </td>';
				strHTML += '       	         <td><span><? echo getByTagName($result->tags,'nrcpfcgc'); ?></span><? $cpf = getByTagName($result->tags,'nrcpfcgc'); if($cpf.length <= 11){ echo formatar($cpf,"cpf");}else{echo formatar($cpf,"cnpj");} ?> </td>';	
				strHTML += '				 <input type="hidden" id="nrregres" name="nrregres" value="<? echo getByTagName($result->tags,'nrregres') ?>" />';
				strHTML += '				 <input type="hidden" id="detsitua" name="detsitua" value="<? if(getByTagName($result->tags,'cdsitreg') == 1) { $dscsitua = "INCLUIDO"; }else{ $dscsitua = "EXCLUIDO";} echo $dscsitua; ?>" />';
				strHTML += '				 <input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($result->tags,'nrcpfcgc') ?>" />';
				strHTML += '				 <input type="hidden" id="nmpessoa" name="nmpessoa" value="<? echo getByTagName($result->tags,'nmpessoa') ?>" />';
				strHTML += '				 <input type="hidden" id="dtinclus" name="dtinclus" value="<? echo getByTagName($result->tags,'dtinclus')." - ".getByTagName($result->tags,'hrinclus') ?>" />';
				strHTML += '				 <input type="hidden" id="dtexclus" name="dtexclus" value="<? if(getByTagName($result->tags,'dtexclus') != ""){echo getByTagName($result->tags,'dtexclus')." - ".getByTagName($result->tags,'hrexclus');} ?>" />';
				strHTML += '				 <input type="hidden" id="dsjusinc" name="dsjusinc" value="<? echo  $aux_dsjusinc; ?>" />';
				strHTML += '				 <input type="hidden" id="nmcopinc" name="nmcopinc" value="<? echo getByTagName($result->tags,'nmcopinc')." - ".getByTagName($result->tags,'nmopeinc') ?>" />';
				strHTML += '				 <input type="hidden" id="nmcopexc" name="nmcopexc" value="<? if(getByTagName($result->tags,'nmcopexc') != ""){echo getByTagName($result->tags,'nmcopexc')." - ".getByTagName($result->tags,'nmopeexc');} ?>" />';
				strHTML += '				 <input type="hidden" id="dsjusexc" name="dsjusexc" value="<? echo getByTagName($result->tags,'dsjusexc') ?>" />';
				strHTML += '				 <input type="hidden" id="tporigem" name="tporigem" value="<? echo getByTagName($result->tags,'tporigem') ?>" />';
				strHTML += '				 <input type="hidden" id="nmpessol" name="nmpessol" value="<? if( getByTagName($result->tags,'nmcopsol') != '' ) {echo getByTagName($result->tags,'nmcopsol')." - ".getByTagName($result->tags,'nmpessol');}else{echo getByTagName($result->tags,'nmpessol');}  ?>" />';
				strHTML += '				 <input type="hidden" id="cdbccxlt" name="cdbccxlt" value="<? echo getByTagName($result->tags,'cdbccxlt') ?>" />';
				strHTML += '				 <input type="hidden" id="nmextbcc" name="nmextbcc" value="<? echo getByTagName($result->tags,'nmextbcc') ?>" />';
				strHTML += '     	       </tr>';	
				<? } ?>
				strHTML += '     </tbody>';	
				strHTML += '  </table>';
				strHTML += '</div>';
				strHTML += '<div id="divRegistrosRodape" class="divRegistrosRodape">';
				strHTML += '	<table>';	
				strHTML += '		<tr>';
				strHTML += '			<td>';
				strHTML += '				<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>';
				strHTML += '				<? if ($nriniseq > 1){ ?>';
				strHTML += '				       <a class="paginacaoAnt"><<< Anterior</a>';
				strHTML += '				<? }else{ ?>';
				strHTML += '						&nbsp;';
				strHTML += '				<? } ?>';
				strHTML += '			</td>';
				strHTML += '			<td>';
				strHTML += '				<? if (isset($nriniseq)) { ?>';
				strHTML += '					   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>';
				strHTML += '					<? } ?>';
				strHTML += '			</td>';
				strHTML += '			<td>';
				strHTML += '				<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>';
				strHTML += '					  <a class="paginacaoProx">Pr&oacute;ximo >>></a>';
				strHTML += '				<? }else{ ?>';
				strHTML += '						&nbsp;';
				strHTML += '				<? } ?>';
				strHTML += '			</td>';
				strHTML += '        </tr>';
				strHTML += '	</table>';
				strHTML += '</div>';	
				strHTML += '</fieldset>';
				strHTML += '<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">';
				strHTML += '	<a href="#" class="botao" id="btVoltar"   onClick="controlaLayout(\'V1\');return false;" >Voltar</a>';
				strHTML += '</div>';
					
				$("#divTabela").html(strHTML);
				tabela('<? echo $cddopcao;?>');
				$("#divTabela").css("display","block");
				$("#divBotoes","#divTabela").css("display","block");
				$("#divOpcoesConsulta").css("display","none");
				$('#divDetalhes').css('display','block');
						
							
			</script>	
			
			<?if($cddopcao == "C"){ 
			     include('form_consulta.php');?>
					
				<script type="text/javascript">
					formataConsulta();
							
				</script>
			<?}else{
			
				include('form_excluir.php');?>
				
				<script type="text/javascript">
					formataExcluir();
					
				</script>
			<?}	
			
		}
			
	}else if($cddopcao == "I"){
	
		    include('form_incluir.php');?>
				
			<script type="text/javascript">
				formataIncluir();
				controlaLayout('<?echo $cddopcao;?>');
				$('#nrcpfcgc','#divDetalhes').focus();
					
			</script>
			  
		 <?
				
	}else if($cddopcao == "L"){

			include('form_liberar.php');?>
				
			<script type="text/javascript">
				formataLiberar();
				controlaLayout('<?echo $cddopcao;?>');
					
			</script>
			  	
	<?}else if($cddopcao == "R"){?>
	
			<script type="text/javascript">
				
				trataImpressao();
					
			</script>
	
	<?}else if($cddopcao == "V"){
	
			include('form_vinculos.php');?>
				
			<script type="text/javascript">
				formataVinculos();
				controlaLayout('<?echo $cddopcao;?>');
				
			</script>
		
	<?}
		
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","estadoInicial();");';
		exit();
	}	
			 
?>



				


				

