/*/{Protheus.doc} MT410LIB
Esse ponto de entrada tem por objetivo verificar a liberaca
o dos pedido por desconto
@author Fabio Cesar Congilio
@since 03.02.04
@version P11
@uso CONNAN
@type function
/*/
User Function MT410LIB()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Local Areas		:= {}      
Local AreasSF4	:= {}         
Local nQtdLib   := 0.00
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Salva a area dos arquivos utilizados                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Areas      	:= GetArea()
dbSelectArea("SF4")
AreasSF4   	:= GetArea()
DbSelectArea("PA2")
AreasPA2	:= GetArea()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Limpa a quantidade liberada caso o usuario nao tenha permissao de liberacao
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If SC5->C5_TIPO $ "N"
	If SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES))
		If SF4->F4_ALCADA == "S"
		    If PA2->(DbSeek(xFilial("PA2")+__cUserId))
		    	If PA2->PA2_LIBTES <> "S"
		    		nQtdLib := 0.00
		    		Aviso("Liberacao", "Usuario sem Permissao de Liberacao!",{"Ok"},,"Atencao:")
		    	EndIf
		    EndIf
		EndIf
	Endif
Endif          
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Retaura a area dos arquivos utilizados                              �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
RestArea(AreasPA2)
RestArea(AreasSF4)
RestArea(Areas)
Return(lReturn)                                 