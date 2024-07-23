#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 21/02/01
#include "Protheus.ch"
#include "Topconn.ch"

User Function MT930SF3()

//Local cQuery := "" 
Local cQueryS:= ""

	/*/
	If cEmpAnt == "20" .and. SF3->F3_ESPECIE = "CF"
 
		cQuery := "UPDATE  " + RetSqlName("SF3") 
		cQuery += "   SET F3_VALICM = ROUND(CAST(F3_BASEICM AS SMALLMONEY) * (CAST(F3_ALIQICM AS SMALLMONEY) / 100),2) "
		cQuery += "  WHERE F3_ESPECIE = 'CF' "
		cQuery += "    AND F3_EMISSAO = '" + DTOS(SF3->F3_EMISSAO) + "' " 
		cQuery += "    AND F3_NFISCAL = '" + SF3->F3_NFISCAL + "' " 
		cQuery += "    AND F3_SERIE   = '" + SF3->F3_SERIE   + "' " 
		cQuery += "    AND F3_CLIEFOR = '" + SF3->F3_CLIEFOR + "' " 
		cQuery += "    AND F3_LOJA    = '" + SF3->F3_LOJA    + "' " 
		cQuery += "    AND F3_FILIAL  = '" + SF3->F3_FILIAL  + "' " 
		cQuery += "    AND D_E_L_E_T_ <> '*' "
	
		TcSqlExec(cQuery)       		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizo a tabela SFT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 
		cQuery := "UPDATE  " + RetSqlName("SFT") 
		cQuery += "   SET FT_VALICM =ROUND(CAST(F3_BASEICM AS SMALLMONEY) * (CAST(F3_ALIQICM AS SMALLMONEY) / 100),2) "
		cQuery += "  WHERE FT_ESPECIE = 'CF' "
		cQuery += "    AND FT_EMISSAO = '" + DTOS(SF3->F3_EMISSAO) + "' " 
		cQuery += "    AND FT_NFISCAL = '" + SF3->F3_NFISCAL + "' " 
		cQuery += "    AND FT_SERIE   = '" + SF3->F3_SERIE   + "' " 
		cQuery += "    AND FT_CLIEFOR = '" + SF3->F3_CLIEFOR + "' " 
		cQuery += "    AND FT_LOJA    = '" + SF3->F3_LOJA    + "' " 
		cQuery += "    AND FT_FILIAL  = '" + SF3->F3_FILIAL  + "' " 
		cQuery += "    AND D_E_L_E_T_ <> '*' "  
	
	EndIf
    /*/                                                    
    //Atualização SF3/SFT - Livro Fiscal  -> Necessario porque tem itens de serviço/materiais com o mssmo código
    //e a Totvs trata o servico por codigo de produto (Cod. ISS) - Chamado 73351 - ROTINA DE REPROCESSAMENTO FISCAL MATA930
	If alltrim(SF3->F3_ESPECIE)	== "NFS" .and. SF3->F3_TIPO <> "S"
 
		cQueryS := "UPDATE  " + RetSqlName("SF3") 
		cQueryS += "   SET F3_TIPO = 'S' "
		cQueryS += "  WHERE F3_ESPECIE = 'NFS' "
		cQueryS += "    AND F3_EMISSAO = '" + DTOS(SF3->F3_EMISSAO) + "' " 
		cQueryS += "    AND F3_NFISCAL = '" + SF3->F3_NFISCAL + "' " 
		cQueryS += "    AND F3_SERIE   = '" + SF3->F3_SERIE   + "' " 
		cQueryS += "    AND F3_CLIEFOR = '" + SF3->F3_CLIEFOR + "' " 
		cQueryS += "    AND F3_LOJA    = '" + SF3->F3_LOJA    + "' " 
		cQueryS += "    AND F3_FILIAL  = '" + SF3->F3_FILIAL  + "' " 
		cQueryS += "    AND D_E_L_E_T_ <> '*' "
	
		TcSqlExec(cQueryS)       		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizo a tabela SFT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 
		cQueryS := "UPDATE  " + RetSqlName("SFT") 
		cQueryS += "   SET FT_TIPO = 'S' "
		cQueryS += "  WHERE FT_ESPECIE = 'NFS' "
		cQueryS += "    AND FT_EMISSAO = '" + DTOS(SF3->F3_EMISSAO) + "' " 
		cQueryS += "    AND FT_NFISCAL = '" + SF3->F3_NFISCAL + "' " 
		cQueryS += "    AND FT_SERIE   = '" + SF3->F3_SERIE   + "' " 
		cQueryS += "    AND FT_CLIEFOR = '" + SF3->F3_CLIEFOR + "' " 
		cQueryS += "    AND FT_LOJA    = '" + SF3->F3_LOJA    + "' " 
		cQueryS += "    AND FT_FILIAL  = '" + SF3->F3_FILIAL  + "' " 
		cQueryS += "    AND D_E_L_E_T_ <> '*' "  
	
		TcSqlExec(cQueryS)       		

	EndIf

Return()