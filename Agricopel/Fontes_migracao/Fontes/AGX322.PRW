#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"    
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma   ³AGX322    ?Autor ?Jean Sérgio Vieira ?Data ? 17/08/10   º±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ?Gerar arquivo texto para emissao de boleto  Bradesco       ³±?
±±?            Para qualquer titulo                                       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso       ?Generico                                                   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Arquivos   ? SA1 - SE1 - SA6                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes ?                                                           ³±?
±±³Necessarias?                                                           ³±?
±±?          ?                                                           ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AGX322
LOCAL cString 	:= "TRB"
LOCAL aStru    := {}
LOCAL cNomCli	:= space(40)
PRIVATE cPerg     := ""
PRIVATE cBanco,cAgencia,xConteudo
PRIVATE nHdlBco   := 0
PRIVATE nHdlSaida := 0
PRIVATE nSeq      := 0
PRIVATE nSomaValor:= 0
PRIVATE aRotina   := { {OemToAnsi("Gerar Arquivo") , "U_A322Gera" , 0 , 0 } }  // "Gerar Arquivo"
PRIVATE nBorderos := 0
PRIVATE xBuffer,nLidos := 0
PRIVATE nTotCnab2 := 0 // Contador de Lay-out nao deletar 
PRIVATE nLinha 	:= 0 // Contador de Linhas nao deletar 
PRIVATE nNossoNum	:= 0 // Contador de Linhas nao deletar 

DbSelectArea("SM0")
cPerg := "AGX322"
If SM0->M0_CODIGO == "01"
	Do Case
		// Se for Filial Agricopel Matriz 
		Case SM0->M0_CODFIL == "01"
			cPerg := "AGX322A"
		// Se for Filial Agricopel Pien
		Case SM0->M0_CODFIL == "02"
			cPerg := "AGX322B"
		// Se for Filial Agricopel Filial II 
		Case SM0->M0_CODFIL == "03"
			cPerg := "AGX322C"				
	EndCase		
EndIf

PRIVATE cCadastro := OemToAnsi("Comunicação Bancária - Envio")  // "Comunica‡„o Banc ria-Envio"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Verifica as perguntas selecionadas                           ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Variaveis utilizadas para parametros                         ?
//?mv_par01             // Do Prefixo                           ?
//?mv_par02             // Ate o Prefixo                        ?
//?mv_par03             // Do Titulo                            ?
//?mv_par04             // Ate o Titulo                         ?
//?mv_par05             // Da Emissao                           ?
//?mv_par06             // Ate a Emissao                        ?
//?mv_par07             // Do Cliente                           ?
//?mv_par08             // Ate o Cliente                        ?
//?mv_par09             // Da Loja                              ?
//?mv_par10             // Ate a Loja                           ?
//?mv_par11		 		 // Arq.Config 		  						  ?
//?mv_par12		 		 // Arq. Saida    	   					  ?
//?mv_par13             // Banco                                ?
//?mv_par14             // Agencia                              ?
//?mv_par15             // Conta                                ?
//?mv_par16             // Sub-Conta                            ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRegistros := {}
AADD(aRegistros,{cPerg,"01","Prefixo de        ?","mv_ch1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Prefixo ate      ?","mv_ch2","C",3,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Doc. de           ?","mv_ch3","C",TamSX3("E1_NUM")[1],0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Doc. ate         ?","mv_ch4","C",TamSX3("E1_NUM")[1],0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"05","Emissao De        ?","mv_ch5","D",8,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"06","Emissao Ate       ?","mv_ch6","D",8,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"07","Cliente De        ?","mv_ch7","C",6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","CLI"})
AADD(aRegistros,{cPerg,"08","Cliente Ate       ?","mv_ch8","C",6,0,0,"G","","mv_par08","","","","","","","","","","","","","","","CLI"})
AADD(aRegistros,{cPerg,"09","Loja De           ?","mv_ch9","C",2,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"10","Loja Ate          ?","mv_ch10","C",2,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"11","Arq. Configuração ?","mv_ch11","C",20,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"12","Arq. Saída        ?","mv_ch12","C",50,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"13","Banco		        ?","mv_ch13","C",3,0,0,"G","","mv_par13","","","","","","","","","","","","","","","SA6"})
AADD(aRegistros,{cPerg,"14","Agencia   	     ?","mv_ch14","C",5,0,0,"G","","mv_par14","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"15","Conta        	  ?","mv_ch15","C",10,0,0,"G","","mv_par15","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"16","Sub-Conta         ?","mv_ch16","C",3,0,0,"G","","mv_par16","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"17","Carteira          ?","mv_ch17","C",6,0,0,"G","","mv_par17","","","","","","","","","","","","","","",""})

U_CriaPer(cPerg,aRegistros)

If !Pergunte(cPerg, .T.)
	Return
Endif

aAdd(aStru,{"OK"		,"C",02,00})
aAdd(aStru,{"NUM"		,"C",TamSX3("E1_NUM")[1],00})
aAdd(aStru,{"PREFIXO","C",03,00})
aAdd(aStru,{"CLIENTE","C",06,00})
aAdd(aStru,{"LOJA"	,"C",02,00})
aAdd(aStru,{"NOMECLI","C",40,00})
aAdd(aStru,{"EMISSAO","D",08,00})

aCampos := { {"OK"		,".T.","  "     		,"@!"},;
				 {"NUM"		,".T.","Num"    		,"@!"},;
				 {"PREFIXO"	,".T.","Prefixo"			,"@!"},;
				 {"CLIENTE"	,".T.","Cliente"		,"@!"},;
				 {"LOJA"		,".T.","Loja"   		,"@!"},;
				 {"NOMECLI"	,".T.","Nome Cliente","@!"},;
				 {"EMISSAO"	,".T.","Dt. Emissão"	,"@!"} }

if Select('TRB') # 0
	dbSelectArea('TRB')
	dbCloseArea()
endif
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,cString,.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua(cString,cInd,"PREFIXO+NUM+CLIENTE+LOJA",,,"Selecionando Registros...")

	
cQuery := ""
cQuery := "SELECT E1_NUM, E1_PREFIXO, E1_CLIENTE, E1_LOJA, E1_EMISSAO "
cQuery += "FROM " + RetSqlName("SE1") + " (NOLOCK) "
cQuery += "WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND E1_FILIAL = '" + xFilial("SE1") + "' "
cQuery += "AND E1_EMISSAO >= '" + DTOS(mv_par05) + "' "
cQuery += "AND E1_EMISSAO <= '" + DTOS(mv_par06) + "' "
cQuery += "AND E1_PREFIXO >= '" + mv_par01 + "' "
cQuery += "AND E1_PREFIXO <= '" + mv_par02 + "' "
cQuery += "AND E1_NUM >= '" + mv_par03 + "' "
cQuery += "AND E1_NUM <= '" + mv_par04 + "' "
cQuery += "AND E1_CLIENTE >= '" + mv_par07 + "' "
cQuery += "AND E1_CLIENTE <= '" + mv_par08 + "' "
cQuery += "AND E1_LOJA >= '" + mv_par09 + "' "
cQuery += "AND E1_LOJA <= '" + mv_par10 + "' "
cQuery += "AND E1_TIPO IN('FT','NCF') "
cQuery += "ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_CLIENTE, E1_LOJA "
cQuery := ChangeQuery(cQuery)
If Select("MSE1") <> 0
	dbSelectArea("MSE1")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MSE1"
TCSetField("MSE1","E1_EMISSAO","D",08,0)
            
dbSelectArea("MSE1")
dbGoTop()
While !Eof()  
	cNomCli := space(40)
	dbSelectArea("SA1")
	dbSetOrder(1)
	if dbSeek(xFilial("SA1")+MSE1->E1_CLIENTE+MSE1->E1_LOJA)
		cNomCli := SA1->A1_NOME	
	endif

	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	TRB->NUM		:= MSE1->E1_NUM
	TRB->PREFIXO:= MSE1->E1_PREFIXO
	TRB->CLIENTE:= MSE1->E1_CLIENTE
	TRB->LOJA	:= MSE1->E1_LOJA
	TRB->NOMECLI:= cNomCli
	TRB->EMISSAO:= MSE1->E1_EMISSAO
	MsUnlock('TRB')

	dbSelectArea("MSE1")
   DbSkip()
EndDo

dbSelectArea(cString)
dbGotop()
cMarca := GetMark()
MarkBrow(cString,'OK',,aCampos,, cMarca,'ExecBlock("A322All",.f.,.f.)',,,,'ExecBlock("A322Mark",.f.,.f.)')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Fecha os Arquivos ASC II                                     ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FCLOSE(nHdlBco)
FCLOSE(nHdlSaida)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ?AGR003Gera?Autor ?Wagner Xavier         ?Data ?26/05/92 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Comunica‡„o Banc ria - Envio Bradesco                      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?AGR003Gera(cAlias)                                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?AGR003                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
User Function A322Gera(cAlias)
Processa({|lEnd| A322Ger(cAlias)})  // Chamada com regua
dbSelectArea("TRB")
dbGotop()
nBorderos  := 0
nSeq		  := 0
nSomaValor := 0  
CloseBrowse()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ?AGR003Ger ?Autor ?Wagner Xavier         ?Data ?26/05/92 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Comunica‡„o Banc ria - Envio Bradesco                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?AGR003Ger()                                                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?AGR003                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function A322Ger(cAlias)
LOCAL cSav7,cSav20,cSavCur,nPosAtu:=0,nPosAnt:=0,nTotRegs:=0,nPosCnt:=0
LOCAL nTamArq:=0,lResp:=.t.
LOCAL lHeader:=.F.,lFirst:=.F.,cSaveMenuh
LOCAL nTam,nDec,nUltDisco:=0,nGrava:=0,aBordero:={}
LOCAL nSavRecno := recno()
Local cDbf
Local lFinCnab2  := .F.
LOCAL oDlg,oBnt,oBmp,nMeter := 1
LOCAL cTexto := "CNAB"
LOCAL lFirstBord := .T.
LOCAL lAchouBord := .F.

LOCAL cNumBorAnt //:= Iif(mv_par13 == "001","BB",Iif(mv_par13 == "237","BR",Iif(mv_par13 == "027","BS","OU")))+StrZero(Day(dDatabase),2)+StrZero(Month(dDatabase),2)

cMes := Space(01)
Do Case 
	Case StrZero(Month(dDatabase),2) == "01"
		cMes := "A"
	Case StrZero(Month(dDatabase),2) == "02"
		cMes := "B"
	Case StrZero(Month(dDatabase),2) == "03"
		cMes := "C"
	Case StrZero(Month(dDatabase),2) == "04"
		cMes := "D"
	Case StrZero(Month(dDatabase),2) == "05"
		cMes := "E"
	Case StrZero(Month(dDatabase),2) == "06"
		cMes := "F"
	Case StrZero(Month(dDatabase),2) == "07"
		cMes := "G"
	Case StrZero(Month(dDatabase),2) == "08"
		cMes := "H"
	Case StrZero(Month(dDatabase),2) == "09"
		cMes := "I"
	Case StrZero(Month(dDatabase),2) == "10"
		cMes := "J"
	Case StrZero(Month(dDatabase),2) == "11"
		cMes := "K"																		
	Case StrZero(Month(dDatabase),2) == "12"
		cMes := "L"
End Case


Do Case
	Case MV_PAR13 == "001"
	   //At?2009 = "B"
		cNumBorAnt := "A"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)
	Case MV_PAR13 == "237" .And. Alltrim(MV_PAR14) == "04130" .And. Alltrim(MV_PAR15) == "00113948" // Para conta Cauçao cfe Fernando/Financeiro 12/12/2006
      //At?2009 = "C"
		cNumBorAnt := "D"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)		
	Case MV_PAR13 == "237"  //Chamado 179990 - Numero de Bordero n?o gerando como E1 para conta 0027                                                                                                     
			cNumBorAnt := "E"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)	
			//Se for essa conta Bradesco, grava border? como 1, a Michele nao estava gerando Remessa pra essa conta quando de outras filiais
			IF Alltrim(MV_PAR15) == '00277207' 
		   		cNumBorAnt := "E"+'1'+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)	
			Endif							
	
	Case MV_PAR13 == "027"	
	   //At?2009 = "S"
		cNumBorAnt := "F"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)	
	Case MV_PAR13 == "TAF"	
	   //At?2009 = "T"
		cNumBorAnt := "G"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)	
End Case        
            
//alert(cNumBorAnt)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Posiciona no Banco indicado                                  ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBanco  := mv_par13
cAgencia:= mv_par14
cConta  := mv_par15
cSubCta := mv_par16

dbSelectArea("SA6")
If !(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
   Help(" ",1,"NAOSA6",,"Dados Bancários Incorretos"+chr(13)+"Informe dados validos!",2,1)
	Return .F.
Endif

dbSelectArea("SEE")
SEE->( dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCta) )

//12/07/2018 - Semaforo de Usuários 
If /*alltrim(SEE->EE_XUSER) <> alltrim(cUserName) .and. */alltrim(SEE->EE_XUSER) <> '' //Adequado, pois usuário faturamento ?utilizado por varios usuarios
	Alert('O Usuário '+alltrim(SEE->EE_XUSER)+' est?utilizando a Rotina, aguarde!' ) 
	Return    
Else 
	dbselectarea('SEE')
    Reclock("SEE")
  		Replace EE_XUSER With alltrim(cUserName)
   	SEE->(MsUnlock())    
Endif

If !SEE->( found() )
	Help(" ",1,"PAR150")  
	dbselectarea('SEE')
    Reclock("SEE")
  		Replace EE_XUSER With ''
   	SEE->(MsUnlock()) 
	Return .F.
Else
	If Val(EE_FAXFIM)-Val(EE_FAXATU) < 100
		Help(" ",1,"FAIXA150")
	Endif
Endif   


//Valida se t?posicionado no Parâmetro Bancario correto
IF  alltrim(SEE->EE_CONTA) <>  alltrim(cConta) .or. alltrim(SEE->EE_AGENCIA) <> alltrim(cAgencia) 
	Alert(' Entre em contat com a TI - Erro Parâmetros bancários incorretos! ')   
	dbselectarea('SEE')
    Reclock("SEE")
  		Replace EE_XUSER With ''
   	SEE->(MsUnlock()) 
	Return
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Posiciona no Bordero Informado pelo usuario                  ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lResp:=AbrePar()	//Abertura Arquivo ASC II

If !lResp
	dbselectarea('SEE')
    Reclock("SEE")
  		Replace EE_XUSER With ''
   	SEE->(MsUnlock()) 
	Return .F.
Endif

nTotCnab2 := 0
nSeq := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Inicia a leitura do arquivo de Titulos                       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGotop()
ProcRegua(TRB->(RecCount()))
While !Eof()
	IncProc()
	If !IsMark( "OK", cMarca )
		dbSelectArea("TRB")
		dbSkip()
		Loop
	Endif
	dbSelectArea("SE1")
	SE1->( dbSetOrder(2) )        
	SE1->( dbSeek(xFilial("SE1")+TRB->CLIENTE+TRB->LOJA+TRB->PREFIXO+TRB->NUM,.T.))	
	SE1->( dbSeek(xFilial("SE1")+TRB->CLIENTE+TRB->LOJA+TRB->PREFIXO+TRB->NUM,.T.))
	While !SE1->( Eof()) .AND. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SE1")+TRB->CLIENTE+TRB->LOJA+TRB->PREFIXO+TRB->NUM
      
		If !Empty(SE1->E1_NUMBOR) .AND. (SE1->E1_NUMBOR <> cNumBorAnt)
		  	SE1->( dbSkip() )
			Loop
		EndIf

//		IF SE1->E1_SITUACA <> "0"
//			SE1->( dbSkip() )
//     		Loop
//		Endif
		
/*		IF Alltrim(SE1->E1_TIPO) == "NCC" .Or.;
		   Alltrim(SE1->E1_TIPO) == "NP"  .Or.;		
		   Alltrim(SE1->E1_TIPO) == "CH" 		
		   SE1->( dbSkip() )
	      Loop
		Endif*/

		IF Alltrim(SE1->E1_TIPO) <> "FT" .AND.  Alltrim(SE1->E1_TIPO) <> "NCF"
		   SE1->( dbSkip() )
	       Loop
		Endif

		IF SE1->E1_EMISSAO <> TRB->EMISSAO
		   SE1->( dbSkip() )
	      Loop
		Endif

		lAchouBord := .T.

	  	SELE SE1
  		reclock('SE1',.f.)
  		SE1->E1_PORTADO := cBanco
  		SE1->E1_AGEDEP  := cAgencia
  		SE1->E1_CONTA   := cConta
  		SE1->E1_VENCREA := DATAVALIDA(SE1->E1_VENCREA+SA6->A6_RETENCA,.T.)
  		se1->e1_numbor  := cNumBorAnt
  		se1->e1_databor := dDataBase
  		se1->e1_situaca := '1'
  		msunlock('SE1')

	  	sele sea
  		dbseek(xfilial('SEA')+SE1->E1_NUMBOR+se1->e1_prefixo+se1->e1_num+se1->e1_parcela+se1->e1_tipo,.t.)
  		while !eof() .and. sea->ea_filial==xfilial('SEA') .and.;
  				SE1->E1_NUMBOR  == SEA->EA_NUMBOR  .and.;
        		se1->e1_prefixo == sea->ea_prefixo .and.;
        		se1->e1_num     == sea->ea_num     .and.;
        		se1->e1_parcela == sea->ea_parcela .and.;
        		se1->e1_tipo    == sea->ea_tipo

      	reclock('SEA',.f.)
      	dbdelete()
        	msunlock('SEA')
        	sele sea
        	skip
        	loop
  		end

  		SELE SEA
  		reclock('SEA',.t.)
  		sea->ea_filial  := xfilial('SEA')
  		sea->ea_prefixo := se1->e1_prefixo
  		sea->ea_num     := se1->e1_num
  		sea->ea_parcela := se1->e1_parcela
  		sea->ea_portado := cBanco
  		sea->ea_agedep  := cAgencia
  		sea->ea_numcon  := cConta
  		sea->ea_numbor  := cNumBorAnt
  		sea->ea_databor := dDataBase
  		sea->ea_tipo    := se1->e1_tipo
  		sea->ea_cart    := 'R'
  		msunlock('SEA')

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	    //?Posiciona no cliente                                         ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA1")
		dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //?Posiciona no Contrato bancario                               ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE9")
		dbSetOrder(1)
		dbSeek(xFilial("SE9")+SE1->(E1_CONTRAT+E1_PORTADO+E1_AGEDEP))
		
		dbSelectArea("SE1")

		nSeq++
		nSomaValor += SE1->E1_SALDO

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Le Arquivo de Parametrizacao                                 ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLidos:=0
		FSEEK(nHdlBco,0,0)
		nTamArq:=FSEEK(nHdlBco,0,2)
		FSEEK(nHdlBco,0,0)
	
		While nLidos <= nTamArq

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Verifica o tipo qual registro foi lido                       ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			xBuffer:=Space(85)
			FREAD(nHdlBco,@xBuffer,85)

			Do Case
				Case SubStr(xBuffer,1,1) == CHR(1)
					IF lHeader
						nLidos+=85
						Loop
					EndIF
				Case SubStr(xBuffer,1,1) == CHR(2)
					IF !lFirst
						lFirst := .T.
						FWRITE(nHdlSaida,CHR(13)+CHR(10))
					EndIF
				Case SubStr(xBuffer,1,1) == CHR(3)
					nLidos+=85
					Loop
				Otherwise
					nLidos+=85
					Loop
			EndCase

			nTam := 1+(Val(SubStr(xBuffer,20,3))-Val(SubStr(xBuffer,17,3)))
			nDec := Val(SubStr(xBuffer,23,1))
			cConteudo:= SubStr(xBuffer,24,60)
			nGrava := A322Grava(nTam,nDec,cConteudo,@aBordero,,lFinCnab2) 
			If nGrava != 1
				Exit
			Endif
			dbSelectArea("SE1")
			nLidos+=85
		EndDO
		If nGrava == 3
			Exit
		Endif
		If nGrava == 1
   		fWrite(nHdlSaida,CHR(13)+CHR(10))
			IF !lHeader
				lHeader := .T.
			EndIF
			dbSelectArea("SEA")
			If (dbSeek(xFilial()+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
				Reclock("SEA")
				SEA -> EA_TRANSF := "S"
				MsUnlock('SEA')
			Endif
	   Endif

		dbSelectArea("SE1")
		SE1->( dbSkip())
	Enddo
	dbSelectArea("TRB")
	dbSkip()
EndDo

If !lAchouBord
	Help(" ",1,"BORD150")
	dbselectarea('SEE')
    Reclock("SEE")
  		Replace EE_XUSER With ''
   	SEE->(MsUnlock()) 
	Return .F.
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Monta Registro Trailler                              		  ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSeq++
nLidos:=0
FSEEK(nHdlBco,0,0)
nTamArq:=FSEEK(nHdlBco,0,2)
FSEEK(nHdlBco,0,0)
While nLidos <= nTamArq

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Tipo qual registro foi lido                                  ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xBuffer:=Space(85)
	FREAD(nHdlBco,@xBuffer,85)

	IF SubStr(xBuffer,1,1) == CHR(3)
		nTam := 1+(Val(SubStr(xBuffer,20,3))-Val(SubStr(xBuffer,17,3)))
		nDec := Val(SubStr(xBuffer,23,1))
		cConteudo:= SubStr(xBuffer,24,60)
		nGrava:=A322Grava( nTam,nDec,cConteudo,@aBordero,.T.,lFinCnab2 )
	 End
	nLidos+=85
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Atualiza Numero do ultimo Disco                              ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SEE")
IF !Eof() .and. nGrava != 3
	Reclock("SEE")
	nUltDisco:=VAL(EE_ULTDSK)  //+1
   Replace EE_ULTDSK With StrZero(nUltDisco,6)
   MsUnlock("SEE")
EndIF
FWRITE(nHdlSaida,CHR(13)+CHR(10))

dbSelectArea( cAlias )
dbGoTo( nSavRecno )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Fecha o arquivo gerado.                                      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FCLOSE(nHdlSaida) 
   
//Limpa campo com nome de Usuário
dbselectarea('SEE')
Reclock("SEE")
	Replace EE_XUSER With ''
SEE->(MsUnlock()) 

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ³AbrePar   ?Autor ?Wagner Xavier         ?Data ?26/05/92 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ³Abre arquivo de Parametros Bradesco                         ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ³AbrePar()                                                   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ³AGR003                                                     ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function AbrePar()
LOCAL cArqEnt:=mv_par11,cArqSaida

IF AT(".",mv_par12)>0
	cArqSaida:=SubStr(TRIM(mv_par12),1,AT(".",mv_par12)-1)+"."+TRIM(SEE->EE_EXTEN)
Else
	cArqSaida:=TRIM(mv_par12)+"."+TRIM(SEE->EE_EXTEN)
EndIF

IF !FILE(cArqEnt)
	Help(" ",1,"NOARQPAR")
	Return .F.
Else
	nHdlBco:=FOPEN(cArqEnt,0+64)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Cria Arquivo Saida                                       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdlSaida:=MSFCREATE(cArqSaida,0)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ³AGR003Grava?Autor ?Wagner Xavier         ?Data ?26/05/92 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ³Rotina de Geracao do Arquivo de Remessa de Comunicacao      ³±?
±±?         ³Bancaria Bradesco                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ³ExpL1:=AGR003Grava(ExpN1,ExpN2,ExpC1)                        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?AGR003                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
STATIC Function A322Grava( nTam,nDec,cConteudo,aBordero,lTrailler,lFinCnab2)
Local nRetorno := 1
Local cTecla   := ""
Local nX       := 1

lTrailler := IIF( lTrailler==NIL, .F., lTrailler ) // Para imprimir o trailler
                                                   // caso se deseje abandonar
                                                   // a gera‡Æo do arquivo
                                                   // de envio pela metade

lFinCnab2 := Iif( lFinCnab2 == Nil, .F., lFinCnab2 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?O retorno podera' ser :                                  ?
//?1 - Grava Ok                                             ?
//?2 - Ignora bordero                                       ?
//?3 - Abandona rotina                                      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While .T.

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //?Verifica se titulo ja' foi enviado                       ?
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
/*    cBordero := xFilial("SEA")+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
    ALERT(cBordero)
    dbSelectArea("SEA")
    If (dbSeek(xFilial("SEA")+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
        If SEA->EA_TRANSF == "S"
            nX := ASCAN(aBordero,SubStr(SE1->E1_NUMBOR,1,6))
            If nX == 0
					nOpc  := 0
					nTipo := 1
					aTipo := {OemToAnsi("Gera com esse border?),OemToAnsi("Ignora esse border?)}

					@ 35,37 TO 188,383 Dialog oDialogos Title OemToAnsi("Bordero Existente")
					@ 11,07 SAY OemToAnsi("O border?n£mero:") SIZE 58, 7 // "O border?n£mero:"
					@ 11,68 GET SE1->E1_NUMBOR When .F. SIZE 37, 10
					@ 24,07 SAY OemToAnsi("j?foi enviado ao banco.") SIZE 82, 7 // "j?foi enviado ao banco."
					@ 37,06 SAY OemToAnsi("Para prosseguir escolha uma das op‡äes")  //"Para prosseguir escolha uma das op‡äes"

					@ 45, 11 RADIO aTipo VAR nTipo // "Gera com esse border?###"Ignora esse border?

					DEFINE SBUTTON FROM 11, 140 TYPE 1 ENABLE OF oDialogos Action (nOpc:=1,oDialogos:End())
					DEFINE SBUTTON FROM 24, 140 TYPE 2 ENABLE OF oDialogos Action (nopc:=0,oDialogos:End())
					Activate Dialog oDialogos Centered

					If nOpc == 1
						If nTipo == 1
							nRetorno := 1
							nBorderos++
						Else
							nRetorno := 2
						EndIf
					Else
						nRetorno := 3
					EndIf				
            Else
                nRetorno := Int(Val(SubStr(aBordero[nX],7,1)))
            End
        End
    End*/
    If nRetorno == 1 .or. ( lTrailler .and. nBorderos > 0 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Analisa conteudo                                         ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF Empty(cConteudo)
			cCampo:=Space(nTam)
		Else
			lConteudo := A322Orig( cConteudo )
			IF !lConteudo
				Exit
			Else
				IF ValType(xConteudo)="D"
					cCampo := GravaData(xConteudo,.F.)
				Elseif ValType(xConteudo)="N"
					cCampo:=Substr(Strzero(xConteudo,nTam,nDec),1,nTam)
				Elseif ValType(xConteudo)="C"
					cCampo:=Substr(xConteudo,1,nTam)
				Else
					cCampo:= Iif(xConteudo,"S","N")
				End
			End
		End
		If Len(cCampo) < nTam  //Preenche campo a ser gravado, caso menor
			cCampo:=cCampo+Space(nTam-Len(cCampo))
		End
		Fwrite( nHdlSaida,cCampo,nTam )
	 EndIf
    If nX == 0
        Aadd(aBordero,Substr(SE1->E1_NUMBOR,1,6)+Str(nRetorno,1))
    End
    Exit
End
Return nRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ³AGR003Orig ?Autor ?Wagner Xavier         ?Data ?10/11/92 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ³Verifica se expressao e' valida para Remessa CNAB.          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ³AGR003                                                     ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function A322Orig( cForm )
        Local bBlock:=ErrorBlock(),bErro := ErrorBlock( { |e| ChecErr260(e,cForm) } )
Private lRet := .T.

BEGIN SEQUENCE
	xConteudo := &cForm
END SEQUENCE
ErrorBlock(bBlock)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ?SomaValor?Autor ?Vinicius Barreira     ?Data ?09/01/95 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Retorna o valor total dos titulos remetidos                ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?SomaValor()                                                ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?Generico                                                   ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function SomaValor()
Return nSomaValor * 100

Static Function A322Process(oDlg,oMeter)
Local ni
oMeter:nTotal := 1000
oMeter:Set(0)
For ni:= 1 to 1000
	oMeter:Set(ni)
	SysRefresh(.t.)
Next
oDlg:End()
Return Nil

Static Function CriaPer(cGrupo,aPer)
***********************************
LOCAL lRetu := .T., aReg  := {}
LOCAL _l := 1, _m := 1, _k := 1

dbSelectArea("SX1")
If (FCount() == 41)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","",""})
	Next _l
ElseIf (FCount() == 39)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],""})
	Next _l
Elseif (FCount() == 26)
	aReg := aPer
Endif

dbSelectArea("SX1")
For _l := 1 to Len(aReg)
	If !dbSeek(cGrupo+StrZero(_l,02,00))
		RecLock("SX1",.T.)
		For _m := 1 to FCount()
			FieldPut(_m,aReg[_l,_m])
		Next _m
		MsUnlock("SX1")
	Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_PERGUNT)
		RecLock("SX1",.F.)
		For _k := 1 to FCount()
			FieldPut(_k,aReg[_l,_k])
		Next _k
		MsUnlock("SX1")
	Endif
Next _l

Return (lRetu)

// Grava marca no campo

User Function A322Mark

If IsMark( 'OK', cMarca )

RecLock( 'TRB', .F. )

Replace OK With Space(2)

MsUnLock('TRB')

Else

RecLock( 'TRB', .F. )

Replace OK With cMarca

MsUnLock('TRB')

EndIf

Return

 

// Grava marca em todos os registros validos

User Function A322All

Local nRecno := Recno()

dbSelectArea('TRB')

dbGotop()

While !Eof()

ExecBlock('A322Mark',.f.,.f.)

dbSkip()

End

dbGoto( nRecno )

Return

Static Function CNossoNum()
******************************
Local cDigito 	:= space(01)

dbSelectArea('SE1')
If Empty(SE1->E1_NUMBCO)
/*   nNossoNum := Val(NossoNum())
   APMSGINFO(nNossoNum)
   cDigito   := CDigitoNosso() 
   nNossoNum := StrZero(nNossoNum,11)+cDigito       

   APMSGINFO(nNossoNum)
	APMSGINFO(cDigito)   
   
   RecLock('SE1',.f.)
   SE1->E1_NUMBCO := nNossoNum
   MsUnlock('SE1') */
   
//******************ALTERADO
	dbSelectArea("SEE")
	DbSetOrder(1)
	DbSeek(xFilial("SEE")+MV_PAR13+MV_PAR14+MV_PAR15+MV_PAR16)
	nNossoNum := Right(Alltrim(SEE->EE_FAXATU),11)

// Garante que o numero tera 11 digitos

	If Len(Alltrim(nNossoNum)) <> 11
	     nNossoNum := Strzero(Val(nNossoNum),11)
	Endif   
	
	//Spiller Estava causando duplicidade de NN
	nNossoNum := Strzero(Val(nNossoNum)+1,11)

	// Verifica se nao estourou o contador, se estourou reinicializa
	// e grava o proximo numero
	dbSelectArea("SEE")
	RecLock("SEE",.F.)
	If nNossoNum == "99999999999"
	     Replace EE_FAXATU With "00000000001"
	Else
	     _nFaxAtu := Val(nNossoNum)// + 1
	     _nFaxAtu := Strzero(_nFaxAtu,12)
	     Replace EE_FAXATU With _nFaxAtu
	Endif
	MsUnlock()


	nNossoNum := val(nNossoNum)
	cDigito   := CDigitoNosso() 
	nNossoNum := StrZero(nNossoNum,11)+cDigito       

 
	RecLock('SE1',.f.)
	SE1->E1_NUMBCO := nNossoNum
	MsUnlock('SE1') 

//***************************

Else
//   nNossoNum := NossoNum()
   nNossoNum := Alltrim(SE1->E1_NUMBCO)
EndIf


Return nNossoNum 

Static Function CDigitoNosso()
******************************
nCont:=0

nSoma1 := val(subs(alltrim(mv_par17),02,1))*2  // Como o campo tem 3 posiçoes no parametro considera as duas ultimas 007 = 07
nSoma2 := val(subs(alltrim(mv_par17),03,1))*7  // Como o campo tem 3 posiçoes no parametro considera as duas ultimas 007 = 07
nSoma3 := val(subs(StrZero(nNossoNum,11),01,1))*6
nSoma4 := val(subs(StrZero(nNossoNum,11),02,1))*5
nSoma5 := val(subs(StrZero(nNossoNum,11),03,1))*4
nSoma6 := val(subs(StrZero(nNossoNum,11),04,1))*3
nSoma7 := val(subs(StrZero(nNossoNum,11),05,1))*2
nSoma8 := val(subs(StrZero(nNossoNum,11),06,1))*7
nSoma9 := val(subs(StrZero(nNossoNum,11),07,1))*6
nSomaA := val(subs(StrZero(nNossoNum,11),08,1))*5
nSomaB := val(subs(StrZero(nNossoNum,11),09,1))*4
nSomaC := val(subs(StrZero(nNossoNum,11),10,1))*3
nSomaD := val(subs(StrZero(nNossoNum,11),11,1))*2

cDigito := mod((nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD),11)

nCont := iif(cDigito == 1, "P", iif(cDigito == 0 , "0", strzero(11-cDigito,1)))
Return nCont