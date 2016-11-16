/**
 * Aplicativo que irá assimilar um arquivo XML enviando-o como repositório de dados para o JASPER (layout),
 * gerando um arquivo PDF conforme especificado.
 */
package br.coop.cecred;

import br.coop.cecred.comum.Comum;
import br.coop.cecred.gerar.GeraRelatorio;
import java.util.regex.Pattern;

/**
 * Classe principal que irá receber os parâmetros para execução de relatório em PDF utilizando layout iReports.
 * Irá receber os parâmetros de execução via linha de comando (shell) em strings (entre aspas) e divididas por espaço.
 * @author Petter - Supero Tecnologia
 * @since Dezembro/2012
 */
public class Main {
     /**
     * Método Main que irá coletar os parâmetros de execução.
     * Controla se o array de parâmetros foi enviado.
     * @param args Array com os parâmetros de execução.
     * 
     * Parâmetros para execução via linha de comando
     * @param arqXML Arquivo XML que irá prover os dados do relatório
     * @param noItera Nó de iteração do XML
     * @param arqJasper Layout do iReports/JasperStudio
     * @param paramValues Array de parâmetros diversos
     * @param pathXML Path e nome do arquivo PDF/TXT
     * @param colunas Quantidade de colunas do relatório
     * 
     */
     public static void main(String[] args) {
        GeraRelatorio geraRelatorio = new GeraRelatorio();
        Comum comum = new Comum();
        String[] arquivo = args[4].split(Pattern.quote("."));
        
        if(args.length == 7){
            if(arquivo[arquivo.length - 1].equals("pdf") || arquivo[arquivo.length - 1].equals("PDF")){
                geraRelatorio.gerarRelatorioPDF(args[0], args[1], args[2], args[3], args[4], args[5], comum);
            }else{
                geraRelatorio.gerarRelatorioTXT(args[0], args[1], args[2], args[3], args[4], args[5], comum, Integer.parseInt(args[6]));
            }
        }else{
            if(arquivo[arquivo.length - 1].equals("pdf") || arquivo[arquivo.length - 1].equals("PDF")){
                 geraRelatorio.gerarRelatorioPDF(args[0], args[1], args[2], "", args[3], args[4], comum);
            }else{
                geraRelatorio.gerarRelatorioTXT(args[0], args[1], args[2], "", args[3], args[4], comum, Integer.parseInt(args[5]));
            }
        }
        
        System.out.println(comum.getGerarPDF());
    }
}