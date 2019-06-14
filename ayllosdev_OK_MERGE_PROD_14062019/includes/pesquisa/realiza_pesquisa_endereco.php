<? 
/*!
 * FONTE        : realiza_pesquisa_endereco.php
 * CRIAÇÃO      : Rodolpho Telmo e Rogérius Militão (DB1)
 * DATA CRIAÇÃO : Abril/2011
 * OBJETIVO     : Realiza a pesquisa endereço
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 
 */ 
?>
 
<?
	session_start();
	require_once("../config.php");
	require_once("../funcoes.php");
	require_once("../controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();		
	
	// recebe o id da rotina
	$idRotina 		= !empty($_POST["idRotina"]) ? $_POST["idRotina"] : 'divPesquisaEndereco';
	
	// Verifica se os parâmetros de desenvolvimento necessários 
	if ( !isset($_POST["auto"    ]) ||
		 !isset($_POST["nriniseq"]) || 
	     !isset($_POST["quantReg"]) || 
		 !isset($_POST["nrcepend"]) ||
		 !isset($_POST["dsendere"]) ||
		 !isset($_POST["nmcidade"]) ||
		 !isset($_POST["cdufende"])) { 
		 exibirErro('error','Parâmetros incorretos para a pesquisa.','Alerta - Aimaro','bloqueiaFundo($(\'#'.$idRotina.'\'))');
	}		
	
	// Pega os valores nas devidas variáveis
	$auto 			= ($_POST["auto"] == 'S') ? 'S' : 'N';
	$idForm 		= $_POST["idForm"];
	$camposOrigem 	= $_POST["camposOrigem"];
	$nriniseq	  	= isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 1;
	$nrregist	 	= isset($_POST["quantReg"]) ? $_POST["quantReg"] : 20;	
	$nrcepend		= $_POST["nrcepend"];
	$dsendere		= $_POST["dsendere"];
	$nmcidade		= $_POST["nmcidade"];
	$cdufende		= $_POST["cdufende"];	

	
	// Monta o xml de requisição
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "  		<Bo>b1wgen0038.p</Bo>";
	$xmlSetPesquisa .= "		<Proc>busca-endereco</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPesquisa .= "	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPesquisa .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetPesquisa .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetPesquisa .= "	<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetPesquisa .= "	<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetPesquisa .= "	<nrcepend>".$nrcepend."</nrcepend>";
	$xmlSetPesquisa .= "	<dsendere>".$dsendere."</dsendere>";
	$xmlSetPesquisa .= "	<nmcidade>".$nmcidade."</nmcidade>";
	$xmlSetPesquisa .= "	<cdufende>".$cdufende."</cdufende>";
	$xmlSetPesquisa .= "	<nrregist>".$nrregist."</nrregist>";
	$xmlSetPesquisa .= "	<nriniseq>".$nriniseq."</nriniseq>";	
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";
	
	// Executa script para envio do XML e Cria objeto para classe de tratamento de XML	
	$xmlResult = getDataXML($xmlSetPesquisa,false);
	$xmlObjPesquisa = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#'.$idRotina.'\'))');
	
	$pesquisa = $xmlObjPesquisa->roottag->tags[0]->tags;	

	// Quantidade total de cooperados na pesquisa
	$qtregist = $xmlObjPesquisa->roottag->tags[0]->attributes["QTREGIST"]; 		
	
	// Explodindo campos Origem
	$campos 	= explode(";",$camposOrigem); // separa os campos
	
	// campos de origem que vão receber os valores da seleção
	$cCep		= $campos[0];
	$cEndereco	= $campos[1];
	$cNumero	= $campos[2];
	$cComple	= $campos[3];
	$cCxPost	= $campos[4];
	$cBairro	= $campos[5];
	$cUf		= $campos[6];
	$cCidade	= $campos[7];
	$cTipo		= $campos[8];
	$cCdOri		= $campos[9];
	$cDsOri     = $campos[10];
	$cNrrowid   = $campos[11];
	$cEndereco2 = $campos[12];
?>	

<script type="text/javascript">		
	var nrcepend 		=  <? echo $nrcepend; ?>;
	var qtregist 		=  <? echo $qtregist; ?>;
	var auto 	 		= '<? echo $auto; ?>';
	var camposOrigem 	= '<? echo $camposOrigem; ?>';
	var idForm 	 		= '<? echo $idForm; ?>';
	var idRotina		= '<? echo $idRotina ?>';
</script>

<div id="divPesquisaItens" class="divPesquisaItens">
	<table id="ResultadoPesquisaEndereco">
		<? 
		// Caso a pesquisa não retornou itens, montar uma célula mesclada com a quantidade colunas que seria exibida
		if ( count($pesquisa) == 0 ) {
			$i = 0;
			$nriniseq = 0;		
			// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
			?> 
			<tr>
				<td colspan="5" style="font-size:12px; text-align:center;">
					<? echo utf8ToHtml('Não existe endereço com os dados informados.'); ?>
				</td>
			</tr> 
			<?						
		} else {				
		
			// Realiza um loop nos registros retornados e desenha cada um em uma linha da tabela
			for($i = 0; $i < count($pesquisa); $i++) {	
				
				// Monto a string, no formato abaixo, que será passada como parâmetro para a função selecionaPesquisa: (campoNome;resultado|campoNome;resultado)
				// A primeira componente de cada item separado pelo pipe "|", o "campoNome" deve casar com a segunda componente "resultado" da seguinte forma:
				// O 1º "campoNome" do Filtro, vai casar com 1º "resultado" das Colunas
				// O 2º "campoNome" do Filtro, vai casar com 2º "resultado" das Colunas, e assim por diante
				
				$registro = $pesquisa[$i]->tags;
				
				// valores selecionados
				$vCep 			= getByTagName($registro,'nrcepend');
				$vEndereco 		= getByTagName($registro,'dsendere');
				$vBairro 		= getByTagName($registro,'nmbairro'); 
				$vCidade 		= getByTagName($registro,'nmcidade');  
				$vUf 			= getByTagName($registro,'cdufende');
				$vComplemento	= getByTagName($registro,'dscmpend');
				$vTipo          = getByTagName($registro,'dstiplog');
				$vCdOrigem      = getByTagName($registro,'idoricad');
				$vDsOrigem      = getByTagName($registro,'dsoricad');
				$vNrrowid       = getByTagName($registro,'nrdrowid');
				$vEndereco2     = getByTagName($registro,'dsender2');
				
				
				$stringParametro = "";	 			
				$stringParametro .= $cCep.";".formataCep($vCep);
				$stringParametro .= "|";	 			
				$stringParametro .= $cEndereco.";".$vEndereco;
				$stringParametro .= "|";	 			
				$stringParametro .= $cComple.";".$vComplemento;
				$stringParametro .= "|";	 			
				$stringParametro .= $cBairro.";".$vBairro;	 			
				$stringParametro .= "|";	 			
				$stringParametro .= $cCidade.";".$vCidade;	 			
				$stringParametro .= "|";	
				$stringParametro .= $cUf.";".$vUf;
				$stringParametro .= "|";	
				$stringParametro .= $cTipo.";".$vTipo;
				$stringParametro .= "|";	
				$stringParametro .= $cCdOri.";".$vCdOrigem;
				$stringParametro .= "|";	
				$stringParametro .= $cDsOri.";".$vDsOrigem;
				$stringParametro .= "|";	
				$stringParametro .= $cNrrowid.";".$vNrrowid;
				$stringParametro .= "|";	
				$stringParametro .= $cEndereco2.";".$vEndereco2;

				$vCep 			= formataCep($vCep);
				$vEndereco 		= stringTabela( $vEndereco, 30, 'palavra' );
				$vBairro 		= stringTabela( $vBairro, 17, 'palavra' ); 
				$vCidade 		= stringTabela( $vCidade, 17, 'palavra' ); 			

				?> 
				<tr onClick="selecionaPesquisaEndereco(<? echo "'".$stringParametro."','".$idForm."','".$cNumero."'" ?>); return false;"> 
				<?	
					?>	
					<td style="width:60px; text-align:center;">
						<? echo $vCep; ?>
						<span class='spanComplemento'><? echo substr($vComplemento,0,80).($vComplemento == '' ? '' : '<br>').$vDsOrigem ?></span>
					</td>
					<td style="width:180px;"><? echo $vEndereco; ?></td>
					<td style="width:100px;"><? echo $vBairro; ?></td>
					<td style="width:100px;"><? echo $vCidade; ?></td>
					<td style="text-align:center"><? echo $vUf; ?></td>					
					<?	
				?>						
				</tr>
				<?
			} // fecha o loop for
		} // fecha o else
		?>			
	</table>
	<br clear="both" />
</div>

<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>	
		<tr>
			<td>
				<?
					
					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) { 
						?> <a class='paginacaoAnt'><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
			</td>
			<td>
				<?
					// Se a paginação não está na &uacute;ltima página, exibe botão proximo
					if ($qtregist > ($nriniseq + $nrregist - 1)) {
						?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
					} else {
						?> &nbsp; <?
					}
				?>			
			</td>
		</tr>
	</table>

</div>

<div id='divComplemento'></div>

<br clear="both" />

<script type="text/javascript">		
	
	// CONTROLE DE PAGINAÇÃO
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		realizaPesquisaEndereco(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."','',''"?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		realizaPesquisaEndereco(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."','',''"?>);
	});

	// CONTROLE DO COMPLEMENTO
    $('#divComplemento').css({'font-size':'10px','height':'28px','margin':'1px 2px','padding':'1px 0px','background-color':'#E7E7E7','color':'#555'});	
	$('.spanComplemento').css({'display':'none','font-size':'small'}).parent().parent().each( function() {
		$(this).unbind('mouseover').bind('mouseover', function() {
			$('#divComplemento').empty().html($('td:first-child > span', $(this)).html());
			return false;
		});
	});
	
	hideMsgAguardo();	
	
	// RESULTADO DA PESQUISA
	if (auto == 'S' && qtregist == 0) {
		limparEndereco( camposOrigem, idForm );
		showError("error","CEP n&atilde;o cadastrado.","Alerta - Aimaro","bloqueiaFundo($('#"+idRotina+"'));");
		
	} else if ( auto == 'S' && qtregist == 1 ) {
		$('tr','#ResultadoPesquisaEndereco').click();
		bloqueiaFundo($('#'+idRotina));	
		
	} else {
		if ( auto == 'S' && qtregist > 1 ) {
			exibeRotina($('#divPesquisaEndereco'));	
			$('input[type=\'text\']:first','#formPesquisaEndereco').focus();		

		}
		bloqueiaFundo($("#divPesquisaEndereco"));
	}
</script>


