/*/{Protheus.doc} MT440LIB
Esse ponto de entrada tem por objetivo verificar a
liberacao automatica dos pedido pelo TES
@author Airton Nakamura
@since 27.07.04
@version P11
@uso CONNAN
@type function
/*/
User Function MT440LIB() 
Local nQtd	:= ParamIxb
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local Areas		:= {}      
Local AreasSF4	:= {}         
Local nQtdLib   := 0.00
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a area dos arquivos utilizados                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Areas      	:= GetArea()
dbSelectArea("SF4")
AreasSF4   	:= GetArea()
DbSelectArea("PA2")
AreasPA2	:= GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa a quantidade liberada caso o usuario nao tenha permissao de liberacao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !isincallstack("TMKA271") 
	If SC5->C5_TIPO $ "N" 
		If SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES))
			If SF4->F4_ALCADA == "S"
			    If PA2->(DbSeek(xFilial("PA2")+__cUserId)) //.and. 
			    	If PA2->PA2_LIBTES <> "S"
			    		nQtdLib := 0.00
			    		Aviso("Liberacao", "Usuario sem Permissao de Liberacao!",{"Ok"},,"Atencao:")
			    	Else
			    		nQtdLib	:= nQtd
			    	EndIf
			    Else
			    	If __cUserId == "000000"
			    		nQtdLib	:= nQtd
			    	Else
			    		nQtdLib := 0.00
			    		Aviso("Liberacao", "Usuario nao encontrado!",{"Ok"},,"Atencao:")		    	
			    	EndIf
			    EndIf
			Else
		   		nQtdLib	:= nQtd		
			EndIf
		Endif
	Endif                                       
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retaura a area dos arquivos utilizados                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(AreasPA2)
RestArea(AreasSF4)
RestArea(Areas)
Return(nQtdLib)                                 