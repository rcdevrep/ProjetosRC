#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#include "totvs.ch"
#include "fwmvcdef.ch"

User Function AGX563()
Local cFilSC6   := ""
Local aIndexSC6 := {}
Local aCpos     := {}
Local aBkRotina := Aclone(aRotina)
Local cTitBrow  := OemToAnsi("BLINK X Protheus")      
Local _cArq     := "T_"+Criatrab(,.F.)
Private aCamposArq := {}  

Private aRotina := {{"Processa","U_VK904CPR", 0,4}}
Private oMark   


Private cAliasTRB := GetNextAlias()
Private cAliasTMP := GetNextAlias()
//Private aRotina := {{"Processa","U_VK904CPR", 0,4}}




	If !CriaSx1()
		Return
	EndIf                    
	
	CriaTab()
	
 //	Carga() //chamo carga
 
 
 	cALiasCapa   := GetNextAlias()
	

	dData1 :=  dtos(mv_par03)
	dData2 :=  dtos(mv_par04)   


	
	
	BeginSql Alias cALiasCapa  
		SELECT PEDIDOS.NUMPEDMOBILE ,PEDIDOS.NUMPED, A1_COD, A1_LOJA, A1_NREDUZ, DTEMISSAO, CAST(IMPORTACAO AS VARCHAR) IMPORTACAO, 
		CAST(DT_LEITURA AS VARCHAR) DT_LEITURA, CODVEND, A3_NOME, CONDPAG,E4_COND,  TOTPED
		FROM INTEGRA_PALM..PEDIDOS (NOLOCK)                                                                                                                      
		INNER JOIN SA1010 (NOLOCK) A1
		ON A1_CGC = CNPJ 
		INNER JOIN SE4010 (NOLOCK) E4
		ON E4_CODIGO = CONDPAG
		INNER JOIN SA3010 (NOLOCK) A3 
		ON A3_COD = CODVEND
		AND A3_FILIAL = FILIAL
		WHERE A1.D_E_L_E_T_ <> '*'
		  AND E4.D_E_L_E_T_ <> '*'
		  AND A3.D_E_L_E_T_ <> '*'
		  AND CODVEND   BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%   
		  AND A1.A1_COD BETWEEN  %Exp:mv_par05% AND %Exp:mv_par06%
		  AND A1.A1_LOJA BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%    
		  AND CONVERT(DATE,IMPORTACAO,103) BETWEEN CONVERT(DATE,%Exp:dData1%,103) AND CONVERT(DATE,%Exp:dData2%,103)
		ORDER BY IMPORTACAO DESC
	EndSql   



dbSelectArea(cALiasCapa)
copy to &_carq
dbUseArea( .T.,__LOCALDRIVER, _cArq,cAliasTRB, .T. , .F. )
dbSelectArea(cALiasTRB)
dbGoTop()


	
/*	DbSelectArea(cALiasCapa)                  
	dbGoTop()
	While !eof() 
	
		dbSelectArea("TRB")
		RecLock("TRB", .T.)
			PEDIDO   := (cALiasCapa)->NUMPEDMOBILE 
			PEDSIGA  := (cALiasCapa)->NUMPED
			CLIENTE  := (cALiasCapa)->A1_COD
			LOJA     := (cALiasCapa)->A1_LOJA
			NOME     := (cALiasCapa)->A1_NREDUZ
			//EMISSAO  := (cALiasCapa)->DTEMISSAO
			IMPORTA  := (cALiasCapa)->IMPORTACAO
		   	LEITURA  := (cALiasCapa)->DT_LEITURA
			CODVEND  := (cALiasCapa)->CODVEND
			NOMVEND  := (cALiasCapa)->A3_NOME
			CONDPAG  := (cALiasCapa)->CONDPAG
			DESCOND  := (cALiasCapa)->E4_COND
			TOTPED   := (cALiasCapa)->TOTPED
		MsUnLock()                                      
		
		dbSelectArea(cALiasCapa)
		dbSkip()	
	EndDo       
	
	dbSelectArea(cALiasCapa)
	dbCloseArea()
    
	dbSelectArea("TRB")
	dbGoTop()      */




	AADD(aCamposArq,{"OK"			,"Gerar"     		,"@!"  		})
	AADD(aCamposArq,{"PEDIDO"       ,"Pedido Blink"       ,"@!"  		})    
	AADD(aCamposArq,{"PEDSIGA"      ,"Pedido Protheus"       ,"@!"  		})    
	AADD(aCamposArq,{"CLIENTE"	    ,"Cliente"          	,"@!"	    })                 	
	AADD(aCamposArq,{"LOJA"	    	,"Loja"	        ,"@!"		})                                                    	
	AADD(aCamposArq,{"NOME"			,"Nome"	        	,"@!"		})
	AADD(aCamposArq,{"EMISSAO"		,"Dt Emissao"	     		,"@!"		})   
	AADD(aCamposArq,{"IMPORTA"		,"Dt Importacao"   		,"@!"		})                                                                   
	AADD(aCamposArq,{"LEITURA"		,"Dt Leitura"   		,"@!"		})                                                                   
	AADD(aCamposArq,{"CODVEND"		,"Representante"   		,"@!"		})       
	AADD(aCamposArq,{"NOMVEND"		,"Nome"   		,"@!"		})   
	AADD(aCamposArq,{"CONDPAG"		,"Cond Pag"   		,"@!"		})   
	AADD(aCamposArq,{"DESCOND"		,"Descricao"   		,"@!"		})   
	AADD(aCamposArq,{"TOTPED"		,"Total Ped"   		,"99999.99"		})    





	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Construcao do MarkBrowse                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMark:= FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	oMark:SetAlias(cALiasTRB)          // Define a tabela do MarkBrowse
	oMark:SetDescription(cTitBrow) // Define o titulo do MarkBrowse
//	oMark:SetFieldMark("OK")    // Define o campo utilizado para a marcacao
  //	oMark:SetFilterDefault(cFilSC6)// Define o filtro a ser aplicado no MarkBrowse
 	oMark:SetFields(aCamposArq)         // Define os campos a serem mostrados no MarkBrowse
 //	oMark:SetSemaphore(.F.)        // Define se utiliza marcacao exclusiva 
 //	oMark:DisableDetails()         // Desabilita a exibicao dos detalhes do Browse
	oMark:Activate() // Ativa o MarkBrowse
	

Return()        



Static Function Carga()
	cALiasCapa   := GetNextAlias()
	

	dData1 :=  dtos(mv_par03)
	dData2 :=  dtos(mv_par04)   


	
	
	BeginSql Alias cALiasCapa  
		SELECT PEDIDOS.NUMPEDMOBILE ,PEDIDOS.NUMPED, A1_COD, A1_LOJA, A1_NREDUZ, DTEMISSAO, CAST(IMPORTACAO AS VARCHAR) IMPORTACAO, 
		CAST(DT_LEITURA AS VARCHAR) DT_LEITURA, CODVEND, A3_NOME, CONDPAG,E4_COND,  TOTPED
		FROM INTEGRA_PALM..PEDIDOS (NOLOCK)                                                                                                                      
		INNER JOIN SA1010 (NOLOCK) A1
		ON A1_CGC = CNPJ 
		INNER JOIN SE4010 (NOLOCK) E4
		ON E4_CODIGO = CONDPAG
		INNER JOIN SA3010 (NOLOCK) A3 
		ON A3_COD = CODVEND
		AND A3_FILIAL = FILIAL
		WHERE A1.D_E_L_E_T_ <> '*'
		  AND E4.D_E_L_E_T_ <> '*'
		  AND A3.D_E_L_E_T_ <> '*'
		  AND CODVEND   BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%   
		  AND A1.A1_COD BETWEEN  %Exp:mv_par05% AND %Exp:mv_par06%
		  AND A1.A1_LOJA BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%    
		  AND CONVERT(DATE,IMPORTACAO,103) BETWEEN CONVERT(DATE,%Exp:dData1%,103) AND CONVERT(DATE,%Exp:dData2%,103)
		ORDER BY IMPORTACAO DESC
	EndSql   
	
	DbSelectArea(cALiasCapa)                  
	dbGoTop()
	While !eof() 
	
		dbSelectArea("TRB")
		RecLock("TRB", .T.)
			PEDIDO   := (cALiasCapa)->NUMPEDMOBILE 
			PEDSIGA  := (cALiasCapa)->NUMPED
			CLIENTE  := (cALiasCapa)->A1_COD
			LOJA     := (cALiasCapa)->A1_LOJA
			NOME     := (cALiasCapa)->A1_NREDUZ
			//EMISSAO  := (cALiasCapa)->DTEMISSAO
			IMPORTA  := (cALiasCapa)->IMPORTACAO
		   	LEITURA  := (cALiasCapa)->DT_LEITURA
			CODVEND  := (cALiasCapa)->CODVEND
			NOMVEND  := (cALiasCapa)->A3_NOME
			CONDPAG  := (cALiasCapa)->CONDPAG
			DESCOND  := (cALiasCapa)->E4_COND
			TOTPED   := (cALiasCapa)->TOTPED
		MsUnLock()                                      
		
		dbSelectArea(cALiasCapa)
		dbSkip()	
	EndDo       
	
	dbSelectArea(cALiasCapa)
	dbCloseArea()
    
	dbSelectArea("TRB")
	dbGoTop()
                       

Return()                 



Static Function CriaTab()                 
	aCampos := {}      
	
	aAdd(aCampos,{"OK"		,"C",02,00})
	aAdd(aCampos,{"PEDIDO"	,"C",25,00}) 
	aAdd(aCampos,{"PEDSIGA"	,"C",06,00})
	aAdd(aCampos,{"CLIENTE"	,"C",06,00})
	aAdd(aCampos,{"LOJA"    ,"C",02,00})
	aAdd(aCampos,{"NOME"	,"C",40,00})
	aAdd(aCampos,{"EMISSAO" ,"D",08,00})
	aAdd(aCampos,{"IMPORTA"	,"C",40,00})
	aAdd(aCampos,{"LEITURA"	,"C",40,00})
	aAdd(aCampos,{"CODVEND"	,"C",06,00})	
	aAdd(aCampos,{"NOMVEND"	,"C",40,00})	
	aAdd(aCampos,{"CONDPAG"	,"C",03,00})	
	aAdd(aCampos,{"DESCOND"	,"C",40,00})
	aAdd(aCampos,{"TOTPED"	,"N",11,02})	

	
	
	
    If Select("TRB") <> 0
       dbSelectArea("TRB")
   	   dbCloseArea()
    Endif

	cArqTrab := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTrab,"TRB",.T.,.F.)

	IndRegua("TRB", cArqTrab, "PEDIDO",,,"Indexando registros..." )

Return()                           



Static Function CriaSx1()
	Private cPerg      := "AXG563"

	PutSx1(cPerg, "01", "Vendedor  de    ?", "" , "", "mv_ch1", "C",TamSX3("A3_COD")[1]  , 0, 2, 'G',"","","","", "mv_par01", "","", "","" ,"","","","","","","","","","","","", "","", "")     
	PutSx1(cPerg, "02", "Vendedor  até   ?", "" , "", "mv_ch2", "C",TamSX3("A3_COD")[1] , 0, 2, 'G',"","","","", "mv_par02", "","", "","" ,"","","","","","","","","","","","", "","", "")    
	PutSx1(cPerg, "03", "Importado de    ?", "" , "", "mv_ch3", "D", 8 , 0, 2, 'G',"","","","", "mv_par03", "","", "","" ,"","","","","","","","","","","","", "","", "")		
	PutSx1(cPerg, "04", "Importado até   ?", "" , "", "mv_ch4", "D", 8 , 0, 2, 'G',"","","","", "mv_par04", "","", "","" ,"","","","","","","","","","","","", "","", "")		
	PutSx1(cPerg, "05", "Cliente de      ?", "" , "", "mv_ch5", "C", 6 , 0, 2, 'G',"","","","", "mv_par05", "","", "","" ,"","","","","","","","","","","","", "","", "")		
	PutSx1(cPerg, "06", "Cliente ate     ?", "" , "", "mv_ch6", "C", 6 , 0, 2, 'G',"","","","", "mv_par06", "","", "","" ,"","","","","","","","","","","","", "","", "")			
	PutSx1(cPerg, "07", "Loja    de      ?", "" , "", "mv_ch7", "C", 2 , 0, 2, 'G',"","","","", "mv_par07", "","", "","" ,"","","","","","","","","","","","", "","", "")			
	PutSx1(cPerg, "08", "Loja    ate     ?", "" , "", "mv_ch8", "C", 2 , 0, 2, 'G',"","","","", "mv_par08", "","", "","" ,"","","","","","","","","","","","", "","", "")	
	
	
Return Pergunte(cPerg,.T.)