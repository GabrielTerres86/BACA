<? 
	
	function isGravavel($dir, $tamanho) {
		
		global $path_abs_documento;

		if (! is_writable($dir)) {
			return "O arquivo ou pasta não pode ser gravado. Permissões insuficientes.";
		}

		
		$tam_disco = disk_free_space($path_abs_documento);
		
		if ($tamanho > $tam_disco) {
			return "O arquivo ou pasta não pode ser gravado. Espaço em disco insuficiente.";
		}
		
		return "";
		
	}
	
	//função que retorna a data anterior 
	function getDateLast($ano,$n_ano,$mes,$n_mes,$dia,$n_dia,$formato){
		$data = mktime (0, 0, 0,$mes - $n_mes, $dia - $n_dia, $ano - $n_ano);
		return date($formato, $data);
	}	

	//função que retorna a data anterior 
	function getParameter($string,$mes, $dia, $ano){
		return date("$string", mktime(0, 0, 0,$mes, $dia, $ano));
	}	
	
	function fnum($VAL,$CASAS="2",$DECIMAL=",",$MILHAR=".") {
		return number_format($VAL,$CASAS,$DECIMAL,$MILHAR);
	}

	//Função para converter a data para formato YYYY-MM-DD
	function cdateYMD($data){
		$dat = split("/",$data);
		$new_date = $dat[2]."-".$dat[1]."-".$dat[0];
		return $new_date;
	}

	//Função para converter a data para formato DD/MM/YYYY
	function cdateDmy($data){
		$dat = split("-",$data);
		$new_date = $dat[2]."/".$dat[1]."/".$dat[0];
		return $new_date;
	}

	//Função que converte a data no formado YYYY-MM-DD para dd/mm/yy e hh:ii:ss conforme o parametro
	function converter_data_hora($data,$formato){

		$data_completa = split(" ",$data);

		$__data = $data_completa[0];
		$__hora = $data_completa[1];
		
		if ($formato == "dia") {
			$_data_c = split("-",$__data);
			return $_data_c[0]."/".$_data_c[1]."/".$_data_c[2];
		}
		else if ($formato == "hora") {
			return $__hora;
		}
		
	}
	
	//Função que converte a data no formado d/m/y para ymd.
	function converter_data_num($data){
		$dat = split("/",$data);
		
		$new_date = $dat[2].$dat[1].$dat[0];
		return $new_date;
	}

	//Função que converte a data no formado ym para ymd.
	function converter_data_num_mes($data){
		$dat = split("/",$data);
		
		$new_date = $dat[2].$dat[1];
		return $new_date;
	}

	//Função que formatar o numero para data
	function format_data($data,$tipo){
		$new_date = "";
		if ($data != ''){
			$ano = substr($data,0,4);
			$mes = substr($data,4,2);
			$dia = substr($data,6,2);
			
			$hora = substr($data,8,2);
			$min  = substr($data,10,2);
								
			$new_date = $dia."/".$mes."/".$ano;
			if ($tipo == "full")
				$new_date .= " ".$hora.":".$min;
		}
		return $new_date;
	}		

	//Função que formatar o numero para data d/m
	function format_dia_mes_data($data){
		$new_date = "";
		if ($data != ''){
			$mes = substr($data,4,2);
			$dia = substr($data,6,2);
			$new_date = $dia."/".$mes;
		}
		return $new_date;
	}		
	

	function TiraAcento($dados){
		 $dados = ereg_replace("[áàâãªä]","a",$dados);
		 $dados = ereg_replace("[ÁÀÂÃÄ]","A",$dados);
		 $dados = ereg_replace("[éèêë]","e",$dados);
		 $dados = ereg_replace("[ÉÈÊË]","E",$dados);
		 $dados = ereg_replace("[íìîï]","i",$dados);
		 $dados = ereg_replace("[ÍÌÏÎ]","I",$dados);
		 $dados = ereg_replace("[óòôõºö]","o",$dados);
		 $dados = ereg_replace("[ÓÒÔÕÖ]","O",$dados);
		 $dados = ereg_replace("[úùûüû]","u",$dados);
		 $dados = ereg_replace("[ÚÙÛÜÛ]","U",$dados);
		 $dados = str_replace("ç","c",$dados);
		 $dados = str_replace("Ç","C",$dados);
		 $dados = ereg_replace(" ","_",$dados);
		 return strtolower($dados);
	}
	
	function getValor($VAR){
	 
		 if (isset($_POST[$VAR]))
			  return $_POST[$VAR];
		 
		 if (isset($_GET[$VAR]))
			  return $_GET[$VAR];	  
	
		 
		 return '';	
	}
	
	//Função para converter tamanhos de Arquivos. Ex.: 1500bytes para 1,5Kb
	function converter_tamanho($TAMANHO){
		$UN = array();
		$UN[0] = "By";
		$UN[1] = "KB";
		$UN[2] = "MB";
		
		$i = 0;
		while ($TAMANHO > 999){
			$TAMANHO = $TAMANHO /1024;
			$i = $i +1;
		}
		$TAMANHO = number_format($TAMANHO,2);
		$TAMANHO .= " ".$UN[$i] ;
		return $TAMANHO;
	}
	
	//Função para retornar apenas alguns caractereres de uma string
	function left($string,$num){
		$len = strlen($string);
		$etc = "";
		if ($len > $num)
			$etc = "...";
				  
		return substr($string,0,$num).$etc;
	
	}
	
	//Função para calcular diferença entre datas;
	function subDayIntoDate($date,$days) {
		 $thisyear = substr ( $date, 0, 4 );
		 $thismonth = substr ( $date, 4, 2 );
		 $thisday =  substr ( $date, 6, 2 );
		 $nextdate = mktime ( 0, 0, 0, $thismonth, $thisday - $days, $thisyear );
		 return strftime("%Y%m%d", $nextdate);
	}
	//Função para somar;
	function addDayIntoDate($date,$days) {
     $thisyear = substr ( $date, 0, 4 );
     $thismonth = substr ( $date, 4, 2 );
     $thisday =  substr ( $date, 6, 2 );
     $nextdate = mktime ( 0, 0, 0, $thismonth, $thisday + $days, $thisyear );
     return strftime("%Y%m%d", $nextdate);
	}
	
	
	//FUNÇÕES PARA CALCULAR DIFERENÇAS DE DATA / HORA
	//Formador Ymd
	function dif_data($DataI, $DataF){
		$DataInicial = getdate(strtotime($DataI)); 
		$DataFinal = getdate(strtotime($DataF)); 
	
		// Calcula a Diferença 
		$Dif = ($DataFinal[0] - $DataInicial[0]) / 60; 
	
		return( $Dif ); 
	}

	function retornaMes(){
		//Rotina para disponibilizar no Menu, os meses do ano atual e ano anterior.
		$mes = array("Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez");
		
		$menuAno = array();
	
		$m=0;
		for ($i=0; $i <= 1; $i++){
			for ($j=0; $j <= 11; $j++){
				$menuAno[$m][1] = $mes[$j]."/".(date("Y")-$i);
				$menuAno[$m][0] = ($j+1)."_".(date("Y")-$i);
				$m++;
			}
		}
	
		return $menuAno;
		//Fim da Rotina pra preencher o Menu Ano.
	}
	
	function getDiaSemana($data){
		
		list ($d, $m, $a) = split ('[/.-]', $data);
		$dia = array("Domingo","Segunda-feira","Terça-feira","Quarta-feira","Quinta-feira","Sexta-feira","Sábado"); 
		

		$diaSemanaCorrente = date("w", mktime(0,0,0,$m,$d,$a));
		return $dia[$diaSemanaCorrente]; 
	
	}
	
	function abrivia_mes($m){
		//Rotina para disponibilizar no Menu, os meses do ano atual e ano anterior.
		$m = (int) $m;
		
		$mes[1] = "Jan";
		$mes[2]	= "Fev";
		$mes[3]	= "Mar";
		$mes[4]	= "Abr";		
		$mes[5]	= "Mai";				
		$mes[6]	= "Jun";
		$mes[7]	= "Jul";
		$mes[8]	= "Ago";
		$mes[9]	= "Set";
		$mes[10]= "Out";
		$mes[11]= "Nov";
		$mes[12]= "Dez";		
		
		return $mes[$m];
		//Fim da Rotina pra preencher o Menu Ano.
	}
	function mes_inteiro($m){
		//Rotina para disponibilizar no Menu, os meses do ano atual e ano anterior.
		$m = (int) $m;
		
		$mes[1] = "Janeiro";
		$mes[2]	= "Fevereiro";
		$mes[3]	= "Março";
		$mes[4]	= "Abril";		
		$mes[5]	= "Maio";				
		$mes[6]	= "Junho";
		$mes[7]	= "Julho";
		$mes[8]	= "Agosto";
		$mes[9]	= "Setembro";
		$mes[10]= "Outubro";
		$mes[11]= "Novembro";
		$mes[12]= "Dezembro";		
		
		return $mes[$m];
		//Fim da Rotina pra preencher o Menu Ano.
	}
	/*
	//Gerando senha de 5 caracteres. 
	echo "Senha com 5 caracteres: <b>" . vc_Key(5) . "</b><br>"; 
	
	//Gerando senha de tamanho aleatóreo. 
	$min=4;  // tamanho minimo da senha 
	$max=80; // tamanho máximo da senha 
	vc_Key(rand($min,$max)) . "</b>";*/
	function vc_Key($lenz){

		$chr_arrz = array("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");

		while(strlen($keyz)<$lenz){
			//Fazendo o sorteio e montando a chave.
			$keyz = $keyz . $chr_arrz[rand(0,35)];
		}
		//Retornando a chave.
		return $keyz;
	}
	
	function getUsuario($CAMPO, $TP=NULL){
		 
		 global $intranet;		 
		 if($TP){			
			$SQL2 = "AND sha(concat(usuario.COD_USUARIO,'PARALELEPIPEDO')) LIKE '" . $CAMPO . "' ";
		 }else{
			$TIPO = is_int($CAMPO);
			 //Busca pelo campo
			 if ($TIPO) {
				$SQL2 = " AND usuario.COD_USUARIO = ".$CAMPO;
			 }
			 else {//Busca por login
				$SQL2 = " AND DES_LOGIN='".$CAMPO."' "; 
			 }
		 }
		 
	  	 $SQL = "SELECT 
					  nivel.COD_NIVEL
					, usuario.COD_USUARIO
					, usuario.COD_CONTATO 
					, usuario.NOM_USUARIO
					, usuario.DES_EMAIL 
					, usuario.DES_LOGIN
					, usuario.DES_SENHA
					, empresa.NOM_EMPRESA
					, depto.NOM_DEPTO
					, contato.NUM_PAC
					, contato.NUM_RAMAL
				FROM
					nivel
					, usuario
					, depto
					, usuario_nivel
					, usuario_depto
					, empresa
					, contato
				WHERE 
						IND_ATIVO = 1
					".$SQL2."
					AND usuario_nivel.COD_NIVEL = nivel.COD_NIVEL
					AND usuario_depto.COD_USUARIO = usuario.COD_USUARIO
					AND usuario_nivel.COD_USUARIO = usuario.COD_USUARIO
					AND depto.COD_DEPTO = usuario_depto.COD_DEPTO
					AND empresa.COD_EMPRESA = depto.COD_EMPRESA
					AND usuario.COD_CONTATO = contato.COD_CONTATO";
		 
		 $retorno = $intranet->Execute($SQL) or die($intranet->ErrorMsg());	

		 return $retorno;
		 
	}
	
	// Função pra limpar caracteres especiais da notícia.
	function limpaNoticia($DES_NOTICIA){
		$DES_NOTICIA = str_replace("'",'"',$DES_NOTICIA);
		return $DES_NOTICIA;
	}
	
	
	//Funcao para retornar data por extenso - formato: Local, Dia de Mês de Ano - Exemplo: Blumenau, 15 de junho de 2009
	//Formato de entrada: dd/mm/yyyy
	function getDataExtenso($data='') {
		if ($data=='') $data = date('Y-m-d');
		$dia = substr($data,0,2);
		$mes = substr($data,3,2);
		$ano = substr($data,6,4);
		$dt = mktime(0, 0, 0, $mes, $dia, $ano);
		return date("j", $dt) . ' de ' . strtolower(mes_inteiro(date('n', $dt))) . ' de ' . date('Y', $dt);
	}



	//Funcao para validar datas no formato DD/MM/YYYY - Jonathan Precise 07/08/2009
	function validaData($data) {
		list($dia,$mes,$ano) = split('/', $data);
		return $data==@date('d/m/Y', @mktime(0,0,0,$mes,$dia,$ano)) || $data==@date('d/m/y', @mktime(0,0,0,$mes,$dia,$ano));
	}
	
