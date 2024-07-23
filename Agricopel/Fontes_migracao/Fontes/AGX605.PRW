#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*
 * ROTINA PARA FAZER ALTERACAO DO CAMPO E5_DTDISPO,
 * NECESSARIO POIS EXISTEM NEGOCIACOES COM O BANCO ONDE O PAGAMENTO FICA 
 * DISPONIVEL PARA AGRICOPEL ALGUNS DIAS APOS O PAGAMENTO TER SIDO EFETUADO
 * ROTINA FOI CRIADA SOMENTE PARA BANCO SAFRA, POREM FOI ALTERADA PARA PODER
 * ALTERAR A DATA DISPO DA BAIXA DE QUALQUER BANCO.
 */ 
 

User Function AGX605()
Local   cRet 	   := ""
Private	cCadastro  := "Alteração Data Disponibilidade - AGX605"
Private	cMarca     := GetMark()
Private bFiltraBrw := {|| Nil }
Private aCamposArq := {} 
Private	aRotina    := {{ "Alterar Data", "U_AGX605_A(),CloseBrowse()", 0, 3},;
					   {"Filtrar", "U_AGX605_F",0,1},;   // INCLUSÃO DA FUNÇÃO FILTRAR - LAYZE RIBAS 19/01/2016
                       {"Desmarc. Todos", "U_AGX605_D",0,2}}
CriaSx1()

If Pergunte("AGX605",.T.)          

	cAliasTrab := GetNextAlias()
	
	Cria_Arq_Tab()
	
	Car_Tit() 
	
	
	AADD(aCamposArq,{"OK"		     ,"","Alterar   "		                   ,"@!" 	 })
  	AADD(aCamposArq,{"E5_DATA"		 ,"","Data"                                ,"@!"     })
	AADD(aCamposArq,{"E5_DTDISPO"    ,"","Data Dispo"                          ,"@!"     })
	AADD(aCamposArq,{"E5_PREFIXO"	 ,"","Prefixo"  			               ,"@!"	 })
	AADD(aCamposArq,{"E5_NUMERO" 	 ,"","Numero"         	                   ,"@!"     })
	AADD(aCamposArq,{"E5_PARCELA"	 ,"","Parcela"			                   ,"@!" 	 })
	AADD(aCamposArq,{"E5_CLIFOR"	 ,"","ClieFor"    		                   ,"@!" 	 })
	AADD(aCamposArq,{"E5_LOJA"       ,"","Loja"			                       ,"@!" 	 })
	AADD(aCamposArq,{"E5_BENEF"      ,"","Nome"			                       ,"@!" 	 })
	AADD(aCamposArq,{"E5_TIPO"       ,"","Tipo"			                       ,"@!" 	 })
	AADD(aCamposArq,{"E5_VALOR"      ,"","Valor"			                   ,"9999999.99" })
	AADD(aCamposArq,{"E5_BANCO"      ,"","Banco"		                       ,"@!" 	 })
	AADD(aCamposArq,{"E5_AGENCIA"    ,"","Agencia"		                       ,"@!" 	 })
	AADD(aCamposArq,{"E5_CONTA"      ,"","Conta"		                       ,"@!" 	 })
	
	DbSelectArea(cAliasTrab)
	dbgotop()
    //MarkBrow ( [ cAlias ] [ cCampo ] [ cCpo ] [ aCampo ] [ lInvert ] [ cMarca ] 
    //[ cCtrlM ] [ uPar8 ] [ cExpIni ] [ cExpFim ] [ cAval ] [ bParBloco ] [ cExprFilTop ] 
    //[ uPar14 ] [ aColors ] [ uPar16 ] [ uPar17 ] [ uPar18 ] [ lShowAmb ] )
	MarkBrowse(cAliasTrab,"OK","",aCamposArq,, cMarca)

EndIf                        


Return()

Static Function Cria_Arq_Tab()
	aCampos := {}       

   	aTam:=TamSX3("E5_DATA")
	AADD(aCampos,{ "E5_DATA"     ,"D",aTam[1],aTam[2] } )
	
	aTam:=TamSX3("E5_DTDISPO")
	AADD(aCampos,{ "E5_DTDISPO"     ,"D",aTam[1],aTam[2] } )

	aTam:=TamSX3("E5_PREFIXO")
	AADD(aCampos,{"E5_PREFIXO"      ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("E5_NUMERO")
	AADD(aCampos,{"E5_NUMERO"     ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("E5_PARCELA")
	AADD(aCampos,{ "E5_PARCELA"    ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("E5_CLIFOR")
	AADD(aCampos,{ "E5_CLIFOR"  ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("E5_LOJA")
	AADD(aCampos,{ "E5_LOJA"  ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("E5_BENEF")
	AADD(aCampos,{ "E5_BENEF"  ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("E5_TIPO")
	AADD(aCampos,{ "E5_TIPO"  ,"C",aTam[1],aTam[2] } )

	aTam:=TamSX3("E5_VALOR")
	AADD(aCampos,{ "E5_VALOR"  ,"N",aTam[1],aTam[2] } )

	AADD(aCampos,{ "E5_REC"     ,"N",10		,0		 } )
	AADD(aCampos,{ "OK"  		,"C",2		,0 		 } )
	
	aTam:=TamSX3("E5_BANCO")
	AADD(aCampos,{ "E5_BANCO"    ,"C",aTam[1],aTam[2] } )
	
	aTam:=TamSX3("E5_AGENCIA")
	AADD(aCampos,{ "E5_AGENCIA"  ,"C",aTam[1],aTam[2] } )
	
	aTam:=TamSX3("E5_CONTA")
	AADD(aCampos,{ "E5_CONTA"    ,"C",aTam[1],aTam[2] } )			

    If Select(cAliasTrab) <> 0
       dbSelectArea(cAliasTrab)
   	   dbCloseArea()
    Endif

	cArqTrab := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTrab,cAliasTrab ,.T.,.F.)

Return()


Static Function Car_Tit()

	cAliasQRY2 := GetNextAlias()

	cQuery := "SELECT E5_DATA,  E5_DTDISPO, E5_NUMERO,E5_PREFIXO ,E5_PARCELA, E5_CLIFOR ,"
	cQuery += "       E5_LOJA,  E5_BENEF,   E5_BENEF, E5_TIPO,   E5_VALOR,    R_E_C_N_O_ REGISTRO, "
	cQuery += "       E5_BANCO, E5_AGENCIA, E5_CONTA    "
	cQuery += " FROM " + RetSqlName("SE5") + " (NOLOCK) "
  	cQuery += "WHERE E5_BANCO = '"+(MV_PAR03)+"'  " 
  	cQuery += "  AND E5_AGENCIA = '"+(MV_PAR04)+"' "
  	cQuery += "  AND E5_CONTA = '"+(MV_PAR05)+"' "  	
	cQuery += "  AND E5_ARQCNAB <> '' "
	cQuery += "  AND E5_DATA   = '" + dtos(mv_par01) + "' " 
	cQuery += "	 AND D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)

    If Select(cAliasQRY2) <> 0
       dbSelectArea(cAliasQRY2)
   	   dbCloseArea()
    Endif

	TCQuery cQuery NEW ALIAS (cAliasQRY2)
	TCSetField((cAliasQRY2), "E5_DATA", "D", 08, 0)
	TCSetField((cAliasQRY2), "E5_DTDISPO", "D", 08, 0)

	dbSelectArea(cAliasQRY2)
	dbGoTop()
	While !Eof()
		dbSelectArea(cAliasTrab)
		RecLock(cAliasTrab,.T.)
		 	E5_DATA   	:=  (cAliasQRY2)->E5_DATA
			E5_DTDISPO	:=  (cAliasQRY2)->E5_DTDISPO
			E5_NUMERO   :=  (cAliasQRY2)->E5_NUMERO
			E5_PREFIXO	:=  (cAliasQRY2)->E5_PREFIXO
			E5_PARCELA  :=  (cAliasQRY2)->E5_PARCELA
			E5_CLIFOR	:=  (cAliasQRY2)->E5_CLIFOR
			E5_LOJA		:=  (cAliasQRY2)->E5_LOJA
			E5_BENEF	:=  (cAliasQRY2)->E5_BENEF
			E5_TIPO		:=  (cAliasQRY2)->E5_TIPO
			E5_VALOR    :=  (cAliasQRY2)->E5_VALOR
			E5_REC      :=  (cAliasQRY2)->REGISTRO
			E5_BANCO    :=  (cAliasQRY2)->E5_BANCO
			E5_AGENCIA  :=  (cAliasQRY2)->E5_AGENCIA
			E5_CONTA    :=  (cAliasQRY2)->E5_CONTA
		MsUnLock()

        dbSelectArea(cAliasQRY2)
       	(cAliasQRY2)->(DbSkip())
	Enddo

	dbSelectArea(cAliasQRY2)
	dbCloseArea()

	dbSelectArea(cAliasTrab)
	dbGoTop()
Return(.T.)      

User Function AGX605_A()
	dbSelectArea(cAliasTrab)
	dbGoTop()
	While !Eof()
		If IsMark("OK", cMarca)
				DbSelectArea("SE5")
				DbGoto((cAliasTrab)->E5_REC)
				RecLock("SE5",.F.)
		   			SE5->E5_DTDISPO  := mv_par02
				MsUnLock("SE5")
		Endif

		dbSelectArea(cAliasTrab)
		(cAliasTrab)->(dbskip())
	EndDo

	MSGBOX("Titulos alterados com sucesso!","Concluido","INFO")

Return    


// INICIO CUSTOMIZAÇÃO
// INCLUSÃO DO BOTÃO FILTRO - LAYZE RIBAS 19/01/2016
User Function AGX605_F()   

Private cPrefixo := Space(100) 
Private cTipo    := Space(100)  
Private cFormEnt := "1"
Private aFormEnt := {"1=Prefixo", "2=Tipo"}    // ITENS DO COMBOBOX

DEFINE MSDIALOG oDlg1 TITLE "Filtro" FROM 000, 000  TO 150, 320 PIXEL

@ 10,010 Combobox cFormEnt Items aFormEnt Size 50,30 pixel of oDlg1
@ 10,060 MsGet cPrefixo Size 80,10 pixel of oDlg1

@ 040,010 BmpButton Type 1 Action {Fil605(cPrefixo), MarkBRefresh(cAliasTrab) ,Close(oDlg1) }
@ 040,040 BmpButton Type 2 Action (Fil605x(),Close(oDlg1))

Activate MsDialog oDlg1 Centered

// FUNÇÃO DE FILTROS
Static Function Fil605 (cPrefixo)

If Alltrim(cFormEnt) == "1" 
	DbSelectArea(cAliasTrab)
	Set Filter To (cAliasTrab)->E5_PREFIXO = Alltrim(cPrefixo)
    // MARCAR OS FILTRADOS
	DbGotop()
	While (cAliasTrab)->(!EOF())
			RecLock((cAliasTrab), .F. )	
				Replace (cAliasTrab)->OK With cMarca	
			MsUnLock()  
	(cAliasTrab)->(DbSkip())
	EndDo      
ElseIf Alltrim(cFormEnt) == "2"
	DbSelectArea(cAliasTrab)
	Set Filter To (cAliasTrab)->E5_TIPO = Alltrim(cPrefixo)  
	// MARCAR OS FILTRADOS
	DbGotop()
	While (cAliasTrab)->(!EOF())
			RecLock((cAliasTrab), .F. )	
				Replace (cAliasTrab)->OK With cMarca	
			MsUnLock()  
	(cAliasTrab)->(DbSkip())
	EndDo    
Else	
	Set Filter To
EndIf
	DbGoTop()
	MarkBRefresh(cAliasTrab)
Return()

// LIMPAR O FILTRO 
Static Function Fil605x()
	Set Filter To    
	DbGotop()
Return()    

User Function AGX605_D()
	DbSelectArea(cAliasTrab)
	DbGotop()
	While (cAliasTrab)->(!EOF())
			RecLock((cAliasTrab), .F. )	
				Replace (cAliasTrab)->OK With Space(2)		
			MsUnLock()  
	(cAliasTrab)->(DbSkip())
	EndDo 
	MarkBRefresh(cAliasTrab)

Return()

// FIM - LAYZE RIBAS 19/01/2016

Return()



Static Function CriaSx1()
   Private cPerg := "AGX605"

 	PutSx1(cPerg, "01", "Data Movimentacao          ?", "" , "", "mv_ch1", "D",  8, 0, 2, 'G',"naovazio()","","","", "mv_par01", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "02", "Data Disponibilidade para  ?", "" , "", "mv_ch2", "D",  8, 0, 2, 'G',"naovazio()","","","", "mv_par02", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "03", "Banco                      ?", "" , "", "mv_ch3", "C",  3, 0, 2, 'G',"naovazio()","","","", "mv_par03", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "04", "Agencia                    ?", "" , "", "mv_ch4", "C",  8, 0, 2, 'G',"naovazio()","","","", "mv_par04", "","", "","" ,"","","","","","","","","","","","", "","", "")
	PutSx1(cPerg, "05", "Conta                      ?", "" , "", "mv_ch5", "C", 10, 0, 2, 'G',"naovazio()","","","", "mv_par05", "","", "","" ,"","","","","","","","","","","","", "","", "")

Return()
