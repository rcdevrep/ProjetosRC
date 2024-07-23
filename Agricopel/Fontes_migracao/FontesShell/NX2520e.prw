#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SF2520    ºAutor  ³Microsiga           º Data ³  06/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para exluir apontamente produto e op caso seja    º±±
±±º          ³ Excluida NF Emitida com OP Gerada no Sistema e Apontada    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function NX2520e()    

lRet	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Manipula a database para efetuar o lancamento contabil da exclusao ³
//³ da Nota Fiscal de Saida com a mesma data de emissão do Documento   ³
//³ -> Necessario pois o usuario mem sempre muda database do Sistema   ³
//³ para Excluir o Documento de Saida                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ddatabase:= SF2->F2_EMISSAO

If SM0->M0_CODIGO == "02" .OR. SM0->M0_CODIGO == '01' .OR. SM0->M0_CODIGO == '44'  // Mime Distrib., Agricopel (Matriz/Pien/Base) e Posto Farol
	aSeg 	   := GetArea()
	aSegSD2  := SD2->(GetArea())
	aSegSC5  := SC5->(GetArea())
	aSegSC6  := SC6->(GetArea())

	SetPrvt("cApOp,lRet")
	cApOp := Space(14)

	
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbGotop()
	DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.)
	While !Eof()	.And. SD2->D2_FILIAL	== xFilial("SD2");
					   .And. SD2->D2_DOC		== SF2->F2_DOC;
					   .And. SD2->D2_SERIE	== SF2->F2_SERIE

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbGotop()
		DbSeek(xFilial("SB1")+SD2->D2_COD,.T.)

		If SB1->B1_GERAOP <> "S"
			DbSelectArea("SD2")
			SD2->(DbSkip())
		EndIf

		DbSelectArea("SC6")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV,.T.)
			
//			EstApont()
			
			ExcApont()		

			ExcOps()
		EndIf
					   
		DbSelectArea("SD2")
		SD2->(DbSkip())					   
	EndDo

	RestArea(aSegSC6)
	RestArea(aSegSC5)		
	RestArea(aSegSD2)
	RestArea(aSeg)
EndIf    

//Chamado[19655] - Boletos para Devolução
If SF2->F2_TIPO == 'D' .AND. U_XAG0053V(SF2->F2_FILIAL)
	           
	DbSelectarea('SE1') 
	If  FieldPos("E1_XCHVNDF") > 0 
		lRet := U_XAG0053E(.T.)
	
		If !lret
			Alert('Entre em contato com o financeiro e Verifique se a NCF '+SF2->F2_DOC+'/'+SF2->F2_SERIE+' foi excluída!')
		Endif
	Endif 
	
Endif  

Return lRet

Static Function EstApont()

	//Monto matriz para estornar requisicao
	///////////////////////////////////////

	cApOp := SC6->C6_NUMOP + "01" + "001"+ "   "

	aAuto1 := {{"D3_OP"      ,cApOp 				,Nil},; //Numero da OP
      		  {"D3_COD"     ,SC6->C6_PRODUTO	,Nil},; //Codigo do Arroz Verde
	           {"D3_LOCAL"   ,SB1->B1_LOCPAD 	,Nil}} //Almoxarifado

	//Chamo rotina para estornar requisicao
	///////////////////////////////////////
	Begin Transaction
		lMsErroAuto := .F.
		MSExecAuto({|x,y|Mata240(x,y)},aAuto1,5)
		If (lMsErroAuto)
			MostraErro()
		Endif
	End Transaction

Return

Static Function ExcApont()

	lMsHelpAuto := .t.  // se .t. direciona as mensagens de help
	
	cApOp := SC6->C6_NUMOP + SC6->C6_ITEMOP + "001" + "   "
			
	aVetor := {}     

	aAdd(aVetor, {"D3_EMISSAO", dDataBase			, Nil})
	If SM0->M0_CODIGO == '03' .OR. (SM0->M0_CODIGO == '01' .AND. SM0->M0_CODFIL == '03') // Mime Distrib. ou Agricopel Base
	   aAdd(aVetor, {"D3_TM"     , "010"				, Nil})
	Endif
	If SM0->M0_CODIGO == '44' // Posto Farol
	   aAdd(aVetor, {"D3_TM"     , "002"				, Nil})
	Endif	
	If (SM0->M0_CODIGO == '01' .AND. (SM0->M0_CODFIL == '01' .OR. SM0->M0_CODFIL =="06")) .OR. (SM0->M0_CODIGO == '01' .AND. SM0->M0_CODFIL == '02') // Agricopel Matriz ou Pien
	   aAdd(aVetor, {"D3_TM"     , "001"				, Nil})
	Endif
	aAdd(aVetor, {"D3_OP"     , cApOp		    	, Nil})
	aAdd(aVetor, {"D3_UM"     , SB1->B1_UM			, Nil})
	aAdd(aVetor, {"D3_COD"    , SC6->C6_PRODUTO	, Nil})
	aAdd(aVetor, {"D3_LOCAL"  , SB1->B1_LOCPAD	, Nil})
	aAdd(aVetor, {"D3_QUANT"  , SD2->D2_QUANT		, Nil})
	
	Begin Transaction
		lMsErroAuto := .f. //necessario a criacao, pois sera
		MsExecAuto({|x,y| Mata250(x,y)},aVetor,5)
		If lMsErroAuto
	  	    Mostraerro()
	  	    lRet := .F.
		EndIf
	End Transaction
Return lRet

Static Function ExcOps()

	Local aRot650 := {}

	aRot650 := {{"C2_NUM"     ,SC6->C6_NUMOP		,Nil},;
					{"C2_ITEM"    ,SC6->C6_ITEMOP		,Nil},;
					{"C2_SEQUEN"  ,"001"	         	,Nil},;
					{"C2_PRODUTO" ,SC9->C9_PRODUTO 	,Nil},;
					{"C2_LOCAL"   ,SB1->B1_LOCPAD  	,Nil},;
					{"C2_QUANT"   ,SC9->C9_QTDLIB  	,Nil},;
					{"C2_UM"      ,SB1->B1_UM      	,Nil},;
					{"C2_DATPRI"  ,dDatabase        	,Nil},;
					{"C2_DATPRF"  ,dDatabase        	,Nil},;
					{"C2_EMISSAO" ,dDatabase        	,Nil},;
					{"C2_TPOP"   ,"F"              	,Nil},;
					{"AUTEXPLODE" ,"S"              	,Nil}}   // Explode a estrutura para gerar SD4 (Empenhos).

	Begin Transaction
		lMsHelpAuto := .t.  // se .t. direciona as mensagens de help
		lMsErroAuto := .f. //necessario a criacao, pois sera
			
		MSExecAuto({|x,y| mata650(x,y)},aRot650,5)
		
		If lMsErroAuto
			DisarmTransaction()
			break
		EndIf	
	End Transaction
	
	If lMsErroAuto
  	    Mostraerro()
		lRet := .f.
	EndIf

Return lRet