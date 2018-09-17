<?
/*!
 * FONTE        : imp_financeiro_pj_html.php.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 06/04/2010 
 * OBJETIVO     : Responsável por buscar as informações que serão apresentadas no PDF da Ficha Cadastral 
 *                da Pessoa Física e montar o HTML.
 *
 * AUTERAÇÕES   : Alteração do indice do valor de faturamento (vlrftbru) de 5 para 8 conforme
 *  			  solicitado no chamado 302427. (Kelvin)
 */	 
?>
<?
	require_once('../../../includes/funcoes.php');
	require_once('../../../class/xmlfile.php');
	
	$xmlObjeto = $GLOBALS['xmlObjeto']; 	
				
	$FinAber  = $xmlObjeto->roottag->tags[26]->tags[0]->tags;
	$FinFicha = $xmlObjeto->roottag->tags[27]->tags[0]->tags;
?>
<style type="text/css">
	pre { 
		font-family: monospace, "Courier New", Courier; 
		font-size:9pt;
	}
	p {
		 page-break-before: always;
		 padding: 0px;
		 margin:0px;	
	}
</style>
<? 
if ( count($FinAber) != 0 ) {
	echo '<pre>';
	
		if ( $GLOBALS['tprelato'] == 'completo' ) echo "<p>&nbsp;</p>"; $GLOBALS['numPagina']++; $GLOBALS['numLinha'] = 0;
		
		escreveLinha( preencheString(getByTagName($FinAber,'nmextcop'),80) );	
		escreveLinha( preencheString(getByTagName($FinAber,'dsendcop'),80) );	
		escreveLinha( preencheString(getByTagName($FinAber,'nrdocnpj'),80) );
		
		pulaLinha(1);	
		
		escreveLinha(  preencheString('INFORMATIVO DE DADOS FINANCEIROS',80,' ','C') );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('--------------------------------------------------------------------------------',80) );
		escreveLinha( preencheString('EMPRESA: '.getByTagName($FinFicha,'nmprimtl'),80) );
		escreveLinha( preencheString('--------------------------------------------------------------------------------',80) );
		escreveLinha( preencheString('C.N.P.J.: '.preencheString(getByTagName($FinFicha,'nrcpfcgc'),41).' Data Base: '.getByTagName($FinFicha,'dsdtbase'),80 ) );
		escreveLinha( preencheString('--------------------------------------------------------------------------------',80) );
		escreveLinha( preencheString('Contas Ativas (Valores em R$)                Contas Passivas (Valores em R$)',80) );
	
		pulaLinha(1);
		
		escreveLinha( preencheString('Caixa,Bancos,Aplicacoes: '.preencheString(getByTagName($FinFicha,'vlcxbcaf'),14,' ','D').'             Fornecedores: '.preencheString(getByTagName($FinFicha,'vlfornec'),13,' ','D'),80 ) );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('       Contas a Receber: '.preencheString(getByTagName($FinFicha,'vlctarcb'),14,' ','D').'          Outros Passivos: '.preencheString(getByTagName($FinFicha,'vloutpas'),13,' ','D'),80 ) );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('               Estoques: '.preencheString(getByTagName($FinFicha,'vlrestoq'),14,' ','D'),80 ) );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('          Outros Ativos: '.preencheString(getByTagName($FinFicha,'vloutatv'),14,' ','D'),80 ) );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('            Imobilizado: '.preencheString(getByTagName($FinFicha,'vlrimobi'),14,' ','D').'   Endividamento Bancario: '.preencheString(getByTagName($FinFicha,'vldivbco'),13,' ','D'),80 ) );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('Ultima Alteracao: '.preencheString(getByTagName($FinFicha[1]->tags,'dtultatu.1'),10).' realizado pelo operador: '.getByTagName($FinFicha[2]->tags,'opultatu.1'),80 ) );
		
		escreveLinha( preencheString('--------------------------------------------------------------------------------',80) );
		
		escreveLinha( preencheString('Emprestimos Bancarios (Saldos de operacao de descontos de cheque/duplicatas)',80) );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('Nome do Banco  Tipo de Operacao       Valor (R$) Garantia           Vencimento',80) );
		
		pulaLinha(1);
		
		for($i = 1; $i <= 5; $i++) {
			$linha = preencheString(getByTagName($FinFicha[14]->tags,'cdbccxlt.'.$i),14);
			$linha .= ' '.preencheString(getByTagName($FinFicha[15]->tags,'dstipope.'.$i),18);
			$linha .= ' '.preencheString(getByTagName($FinFicha[16]->tags,'vlropera.'.$i),14,' ','D');
			$linha .= ' '.preencheString(getByTagName($FinFicha[17]->tags,'garantia.'.$i),18);
			$linha .= ' '.preencheString(getByTagName($FinFicha[18]->tags,'dsvencto.'.$i),12);
			escreveLinha( $linha );
			
			pulaLinha(1);
		}
		
		escreveLinha( preencheString('Ultima Alteracao: '.preencheString(getByTagName($FinFicha[1]->tags,'dtultatu.2'),10).' realizado pelo operador: '.getByTagName($FinFicha[2]->tags,'opultatu.2'),80 ) );
		escreveLinha( preencheString('--------------------------------------------------------------------------------',80) );
		escreveLinha( preencheString('Contas de Resultados (ultimos 12 meses/valores em R$)    Prazos Medios (em dias)',80) );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('         Receita Bruta de Vendas: '.preencheString(getByTagName($FinFicha,'vlrctbru'),19,' ','D').'    Recebimentos: '.preencheString(getByTagName($FinFicha,'ddprzrec'),9,' ','D'),80 ) );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('Custo e Despesas Administrativas: '.preencheString(getByTagName($FinFicha,'vlctdpad'),19,' ','D').'      Pagamentos: '.preencheString(getByTagName($FinFicha,'ddprzpag'),9,' ','D'),80 ) );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('            Despesas Financeiras: '.preencheString(getByTagName($FinFicha,'vlctdpad'),19,' ','D'),80 ) );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('Ultima Alteracao: '.preencheString(getByTagName($FinFicha[1]->tags,'dtultatu.3'),10).' realizado pelo operador: '.getByTagName($FinFicha[2]->tags,'opultatu.3'),80 ) );
		escreveLinha( preencheString('--------------------------------------------------------------------------------',80) );
		escreveLinha( preencheString('Relacao do Faturamento Mensal Bruto dos ultimos 12 meses (valores em R$)',80) );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('    Mes/Ano    Faturamento     Mes/Ano    Faturamento     Mes/Ano    Faturamento',80) );
		
		$linha = '1.  '.preencheString(getByTagName($FinFicha[25]->tags,'mesanoft.1'),7,' ','D');
		$linha .= ' '.preencheString(getByTagName($FinFicha[26]->tags,'vlrftbru.1'),14,' ','D');
		$linha .= ' 2.  '.preencheString(getByTagName($FinFicha[25]->tags,'mesanoft.2'),7,' ','D');
		$linha .= ' '.preencheString(getByTagName($FinFicha[26]->tags,'vlrftbru.2'),14,' ','D');
		$linha .= ' 3.  '.preencheString(getByTagName($FinFicha[25]->tags,'mesanoft.3'),7,' ','D');
		$linha .= ' '.preencheString(getByTagName($FinFicha[26]->tags,'vlrftbru.3'),14,' ','D');
		escreveLinha( $linha );
		
		pulaLinha(1);
		
		$linha = '4.  '.preencheString(getByTagName($FinFicha[25]->tags,'mesanoft.4'),7,' ','D');
		$linha .= ' '.preencheString(getByTagName($FinFicha[26]->tags,'vlrftbru.4'),14,' ','D');
		$linha .= ' 5.  '.preencheString(getByTagName($FinFicha[25]->tags,'mesanoft.5'),7,' ','D');
		$linha .= ' '.preencheString(getByTagName($FinFicha[26]->tags,'vlrftbru.5'),14,' ','D');
		$linha .= ' 6.  '.preencheString(getByTagName($FinFicha[25]->tags,'mesanoft.6'),7,' ','D');
		$linha .= ' '.preencheString(getByTagName($FinFicha[26]->tags,'vlrftbru.6'),14,' ','D');
		escreveLinha( $linha );
		
		pulaLinha(1);
		
		$linha = '7.  '.preencheString(getByTagName($FinFicha[25]->tags,'mesanoft.7'),7,' ','D');
		$linha .= ' '.preencheString(getByTagName($FinFicha[26]->tags,'vlrftbru.7'),14,' ','D');
		$linha .= ' 8.  '.preencheString(getByTagName($FinFicha[25]->tags,'mesanoft.8'),7,' ','D');
		$linha .= ' '.preencheString(getByTagName($FinFicha[26]->tags,'vlrftbru.8'),14,' ','D');
		$linha .= ' 9.  '.preencheString(getByTagName($FinFicha[25]->tags,'mesanoft.9'),7,' ','D');
		$linha .= ' '.preencheString(getByTagName($FinFicha[26]->tags,'vlrftbru.9'),14,' ','D');
		escreveLinha( $linha );
		
		pulaLinha(1);
		
		$linha = '10. '.preencheString(getByTagName($FinFicha[25]->tags,'mesanoft.10'),7,' ','D');
		$linha .= ' '.preencheString(getByTagName($FinFicha[26]->tags,'vlrftbru.10'),14,' ','D');
		$linha .= ' 11. '.preencheString(getByTagName($FinFicha[25]->tags,'mesanoft.11'),7,' ','D');
		$linha .= ' '.preencheString(getByTagName($FinFicha[26]->tags,'vlrftbru.11'),14,' ','D');
		$linha .= ' 12. '.preencheString(getByTagName($FinFicha[25]->tags,'mesanoft.12'),7,' ','D');
		$linha .= ' '.preencheString(getByTagName($FinFicha[26]->tags,'vlrftbru.12'),14,' ','D');
		escreveLinha( $linha );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('Ultima Alteracao: '.preencheString(getByTagName($FinFicha[1]->tags,'dtultatu.4'),10).' realizado pelo operador: '.getByTagName($FinFicha[2]->tags,'opultatu.4'),80 ) );
		escreveLinha( preencheString('--------------------------------------------------------------------------------',80) );
		escreveLinha( preencheString('Informacoes Adicionais:',80) );
		
		for($i = 1; $i <= 5; $i++) { 
			escreveLinha( preencheString( getByTagName($FinFicha[27]->tags ,'dsinfadi.'.$i),80 ) );
		}
		
		pulaLinha(1);
		
		escreveLinha( preencheString('Ultima Alteracao: '.preencheString(getByTagName($FinFicha[1]->tags,'dtultatu.5'),10).' realizado pelo operador: '.getByTagName($FinFicha[2]->tags,'opultatu.5'),80 ) );
		escreveLinha( preencheString('--------------------------------------------------------------------------------',80) );
		escreveLinha( preencheString('Representante(s) Legal(is):',80) );
		
		pulaLinha(1);
		
		escreveLinha( preencheString('Nome:_____________________________________________   CPF:_______________________',80) );
		
		pulaLinha(2);
		
		escreveLinha( preencheString('Nome:_____________________________________________   CPF:_______________________',80) );
	echo '</pre>';
}	
?>