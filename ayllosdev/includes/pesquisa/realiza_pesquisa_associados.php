<? 
/*!
 * FONTE        : realiza_pesquisa_associados.php
 * CRIA��O      : Rodolpho Telmo (DB1)
 * DATA CRIA��O : 16/03/2010
 * OBJETIVO     : Efetuar pesquisa de associados de modo gen�rico, para ser utilizada por diversas telas
 * --------------
 * ALTERA��ES   :
 * --------------
 * 001: [22/10/2020] David       (CECRED)   : Incluir novo parametro para a funcao getDataXML (David).
 * 002: [05/11/2010] Gabriel     (CECRED)   : Incluir novo parametro para a organiza��o da pesquisa.	
 * 003: [24/10/2011] Rogerius Milit�o (Db1) : Adicionado a op��o de pesquisar o associado pelo CPF/CNPJ
 * 004: [09/08/2013] Carlos (CECRED)        : Altera��o da sigla PAC para PA.
 */ 
?>

<?	
	session_start();
	require_once("../config.php");
	require_once("../funcoes.php");	
	require_once("../controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();	
	
	// Verifica se os par�mtros necess�rios foram informados
	if (!isset($_POST["cdpesqui"]) || 
		!isset($_POST["nmdbusca"]) || 
		!isset($_POST["tpdapesq"]) || 
		!isset($_POST["cdagpesq"]) || 
		!isset($_POST["nrdctitg"])) {
		exibirErro('error','Par&acirc;metros incorretos para a pesquisa.','Alerta - Ayllos','bloqueiaFundo($(\'#divConsultaAssociado\'))',true);
	}	
	
	$cdpesqui = $_POST["cdpesqui"];
	$nmdbusca = $_POST["nmdbusca"];
	$tpdapesq = $_POST["tpdapesq"];
	$cdagpesq = $_POST["cdagpesq"];
	$nrdctitg = $_POST["nrdctitg"];
	$tpdorgan = $_POST["tpdorgan"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	
	
	// Dados para pagina��o dos cooperados
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 1;
	$nrregist = 50;	
	
	$teste = $cdpesqui." | ".$nmdbusca." | ".$tpdapesq." | ".$cdagpesq." | ".$nrdctitg;	

	// Verifica se tipo de pesquisa � v�lido
	if (!validaInteiro($cdpesqui) || ($cdpesqui <> "1" && $cdpesqui <> "2" && $cdpesqui <> "3")) exibirErro('error','Tipo de pesquisa inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo($(\'#divConsultaAssociado\'))',true);
	
	// Valida tipo de titular
	if ($cdpesqui == "1" && (!validaInteiro($tpdapesq) || $tpdapesq < 0 || $tpdapesq > 4)) exibirErro('error','Tipo de Titular inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo($(\'#divConsultaAssociado\'))',true);

	// Valida tipo de titular
	if ($cdpesqui == "3" && (!validaInteiro($tpdapesq) || $tpdapesq < 1 || $tpdapesq > 2)) exibirErro('error','Tipo de Pesquisa inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo($(\'#divConsultaAssociado\'))',true);
	
	// Verifica se c�dgio do PA � um inteiro v�lido
	if ($cdpesqui == "1" && !validaInteiro($cdagpesq)) exibirErro('error','C&oacute;digo de PA inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo($(\'#divConsultaAssociado\'))',true);
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0059.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>zoom-associados</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPesquisa .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPesquisa .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetPesquisa .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetPesquisa .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetPesquisa .= "		<cdpesqui>".$cdpesqui."</cdpesqui>";
	$xmlSetPesquisa .= "		<nmdbusca>".$nmdbusca."</nmdbusca>";
	$xmlSetPesquisa .= "		<tpdapesq>".$tpdapesq."</tpdapesq>";
	$xmlSetPesquisa .= "		<cdagpesq>".$cdagpesq."</cdagpesq>";
	$xmlSetPesquisa .= "		<nrdctitg>".$nrdctitg."</nrdctitg>";
	$xmlSetPesquisa .= "        <tpdorgan>".$tpdorgan."</tpdorgan>";
	$xmlSetPesquisa .= "        <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlSetPesquisa .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xmlSetPesquisa .= "		<nrregist>".$nrregist."</nrregist>";
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";			
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPesquisa,false);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPesquisa = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo($(\'#divConsultaAssociado\'))');
	
	$pesquisa = $xmlObjPesquisa->roottag->tags[0]->tags;

	// Quantidade total de cooperados na pesquisa
	$qtcopera = $xmlObjPesquisa->roottag->tags[0]->attributes["QTCOPERA"]; 
?>

<div id="divPesquisaAssociadoItens" class="divPesquisaItens">
	<table>
		<tbody>
			<? 
			// Caso a pesquisa n�o retornou itens, montar uma c�lula mesclada com a quantidade colunas que seria exibida
			if ( count($pesquisa) == 0 ) { 
				$i = 0;					
				// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
				?> <tr><td colspan="3" style="font-size:12px; text-align:center;">N&atilde;o existe associado com os dados informados.</td></tr> <?		
			// Caso a pesquisa retornou itens, exib�los em diversas linhas da tabela
			} else {  
				// Realiza um loop nos registros retornados e desenha cada um em uma linha da tabela
				for($i = 0; $i < count($pesquisa); $i++) { ?>				 
					<tr onClick="selecionaAssociado(<? echo "'".getByTagName($pesquisa[$i]->tags,'nrdconta')."'"; ?>); return false;">
						
					
						<td style="width:35px; font-size:11px ;text-align:right;">
							<? echo getByTagName($pesquisa[$i]->tags,'cdagenci'); ?>
						</td>
												
						<td style="width:70px;text-align:right;font-size:11px;">
							<? echo formataContaDV(getByTagName($pesquisa[$i]->tags,'nrdconta')); ?>
						</td> 
						<td style="width:260px;font-size:11px;">
							<? echo formataContaDV(getByTagName($pesquisa[$i]->tags,'nmprimtl')); ?>
						</td> 
						<td style="width:60px;font-size:11px;">
							<? 
								$contaIntegracao = (getByTagName($pesquisa[$i]->tags,'nrdctitg') == '') ? '' : formataNumericos("z.zzz.zzz-z",getByTagName($pesquisa[$i]->tags,'nrdctitg'),".-");
								echo $contaIntegracao; 
							?>
						</td> 
					</tr> 
				<? } // fecha o loop for		
			} // fecha else ?> 
		</tbody>
	</table>
	<br clear="both" />
</div>

<div id="divPesquisaAssociadoRodape" class="divPesquisaRodape">
	<table>
		<tr>
			<td>
				<?
					// Se a pagina��o n�o est� na primeira, exibe bot�o voltar
					if ($nriniseq > 1) { 
						?> <a onClick="pesquisaAssociado(<? echo ($nriniseq - $nrregist); ?>); return false;"><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtcopera) { echo $qtcopera; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtcopera; ?>
			</td>
			<td>
				<?
					// Se a pagina��o n�o est� na �ltima p�gina, exibe bot�o proximo
					if ($qtcopera > ($nriniseq + $nrregist - 1)) {
						?> <a onClick="pesquisaAssociado(<? echo ($nriniseq + $nrregist); ?>); return false;">Pr&oacute;ximo >>></a> <?
					} else { 
						?> &nbsp; <?
					}
				?>			
			</td>
		</tr>
	</table>
</div>

<script type="text/javascript">		
	hideMsgAguardo();
	bloqueiaFundo($("#divPesquisaAssociado"));
</script>