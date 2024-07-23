
//#INCLUDE "MATA805.ch"
#INCLUDE "PROTHEUS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"


User Function AGX551()
Local cCounter	:= '0001'	//StrZero(0,TamSx3('DB_ITEM')[1])   

	ALERT("COMECOU BF")

	cQuery := "SELECT * FROM SBF010 BF INNER JOIN SB1010 B1 ON B1_FILIAL = BF_FILIAL AND B1_COD = BF_PRODUTO WHERE BF_FILIAL = '06' "
	cQuery += "  AND BF.D_E_L_E_T_ <> '*'  AND B1.D_E_L_E_T_ <> '*'  AND B1_RASTRO = 'N'  AND BF_LOTECTL <> ''  AND BF.BF_LOCAL = '01' "

	If (Select("QRY_SBF") <> 0)
		dbSelectArea("QRY_SBF")	
		dbCloseArea()
	Endif
	
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRY_SBF"
	
	dbSelectArea("QRY_SBF")
	ProcRegua(500)
	dbGoTop()
	While !Eof()
		
		cCounter := Soma1(cCounter)  
		
			
		dbSelectArea("SB1")
		dbSetOrder(1)
	    if !dbseek(xFilial("SB1")+QRY_SBF->BF_PRODUTO)
	      conout("Atenção! Produto não encontrado!")
	    EndIf
	    
	    
	    
   		cProdAtv := SB1->B1_SITUACA 
		cProdBlq := SB1->B1_MSBLQL
		
		RecLock("SB1",.F.)
			SB1->B1_SITUACA := "1"
			SB1->B1_MSBLQL	:= "2"		
		MsUnlock( )  

		nQtdDif := 0        
		nQtd   := 0
		nQtdEnd := QRY_SBF->BF_QUANT

        cTipoMov := "499" //Entrada

         //Verifico o valor que deve estar em estoque
         
         Do Case
            Case nQtdEnd < 0 
	            nQtdDif := nQtd + (nQtdEnd*(-1)) 
	            cTipoMov := "499" //Entrada
	        Case nQtd > nQtdEnd
	            nQtdDif := nQtd - nQtdEnd 
	            cTipoMov := "999" //Entrada
	        Case nQtd < nQtdEnd
				nQtdDif := nQtdEnd - nQtd
	            cTipoMov := "999" //saida           
	     EndCase     
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria registro de movimentacao por Localizacao (SDB)           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
					

		CriaSDB(QRY_SBF->BF_PRODUTO,;	// Produto
				QRY_SBF->BF_LOCAL,;	// Armazem
			    nQtdDif,;	// Quantidade
				QRY_SBF->BF_LOCALIZ,;	// Localizacao
				"",;	// Numero de Serie
				"ACERTO",;		// Doc
				"UNI",;		// Serie
				"",;			// Cliente / Fornecedor
				"",;			// Loja
				"",;			// Tipo NF
				"SDB",;			// Origem do Movimento
				dDataBase,;		// Data
				QRY_SBF->BF_LOTECTL,;	// Lote
				"",; // Sub-Lote
				ProxNum(),;		// Numero Sequencial
				cTipoMov,;			// Tipo do Movimento
				"M",;			// Tipo do Movimento (Distribuicao/Movimento)
				cCounter,;		// Item
				.F.,;			// Flag que indica se e' mov. estorno
				0,;				// Quantidade empenhado
				0)		// Quantidade segunda UM
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma saldo em estoque por localizacao fisica (SBF)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GravaSBF("SDB")
		

		dbSelectArea("SB1")
		RecLock("SB1",.F.)
			SB1->B1_SITUACA := cProdAtv
			SB1->B1_MSBLQL	:= cProdBlq
		MsUnlock( )  
        
        dbSelectArea("QRY_SBF")
        QRY_SBF->(dbSkip())
	EndDo                                 
	ALERT("FIM")
	 
Return()